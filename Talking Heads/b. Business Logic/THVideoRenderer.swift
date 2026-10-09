//
//  THVideoRenderer.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation
import CoreGraphics
import CoreImage
import AVFoundation
import AppKit
import ImageIO
import UMVideoComposer

/// Renders a Talking Heads scene into a complete MP4 video using UMVideoComposer.
actor THVideoRenderer {

	/// Generates a composite video for a given scene.
	/// - Parameters:
	///   - scene: The scene to render.
	///   - projectURL: The root directory URL of the `.thproject` bundle.
	///   - shots: The pool of all shots.
	/// - Returns: The relative path to the rendered video file.
	func render (
		scene: THScene,
		projectURL: URL,
		shots: [THShot],
		progress: (@Sendable (Double) -> Void)? = nil
	) async throws -> String {
		
		guard let audioSequence = scene.audioSequence else {
			throw NSError (domain: "THVideoRenderer", code: 400, userInfo: [NSLocalizedDescriptionKey: "No audio track available. Please import audio first."])
		}
		guard let transcript = scene.transcript else {
			throw NSError (domain: "THVideoRenderer", code: 400, userInfo: [NSLocalizedDescriptionKey: "No transcript available. Please transcribe audio first."])
		}
		
		// 1. Setup folders
		let fm = FileManager.default
		let rendersDir = projectURL.appendingPathComponent ("renders")
		if !fm.fileExists (atPath: rendersDir.path) {
			try fm.createDirectory (at: rendersDir, withIntermediateDirectories: true)
		}
		
		let outputFilename = "scene_\(scene.id.uuidString.prefix(8)).mp4"
		let outputURL = rendersDir.appendingPathComponent (outputFilename)
		
		// 2. Resolve resolution from aspect ratio
		let resolution: CGSize
		switch scene.aspectRatio {
		case .ar_1_1:	resolution = CGSize (width: 1080, height: 1080)
		case .ar_9_16:	resolution = CGSize (width: 1080, height: 1920)
		case .ar_16_9:	resolution = CGSize (width: 1920, height: 1080)
		case .ar_3_4:	resolution = CGSize (width: 1080, height: 1440)
		case .ar_4_3:	resolution = CGSize (width: 1440, height: 1080)
		case .ar_2_3:	resolution = CGSize (width: 1080, height: 1620)
		case .ar_3_2:	resolution = CGSize (width: 1620, height: 1080)
		case .ar_21_9:	resolution = CGSize (width: 2520, height: 1080)
		}
		
		// 3. Compute the frames of the timeline (at 30 fps)
		let fps = 30.0
		let frameDuration = 1.0 / fps
		let totalFrames = Int (ceil (audioSequence.duration * fps))
		
		let blinkCycle = 4.0
		
		// Temporary struct to keep track of a frame's properties
		struct FrameInfo {
			var shot: THShot
			var variant: THFrameVariant
			var imageURL: URL
			var scaleFactor: CGFloat
		}
		
		var frames: [FrameInfo?] = []
		var currentSpeechFrameCount = 0
		var scaleFactorCache: [URL: CGFloat] = [:]
		
		for k in 0..<totalFrames {
			let mid = (Double(k) + 0.5) * frameDuration
			
			// Find sentence covering mid
			let activeSentence = transcript.sentences.first { mid >= $0.startTime && mid <= $0.endTime }
			
			// Map shot
			var activeShot: THShot? = nil
			if let sentence = activeSentence {
				if let assignment = scene.shotAssignments.first(where: { $0.sentenceId == sentence.id }),
				   let shot = shots.first(where: { $0.id == assignment.shotId }) {
					activeShot = shot
				}
			}
			// Fallback to cycling/alternating shots based on speech clusters if no manual assignment exists
			if activeShot == nil {
				let sceneShots = shots.filter { scene.shotIds.contains ($0.id) }
				let approvedShots = sceneShots.filter { $0.isApproved }
				let cyclePool = approvedShots.isEmpty ? sceneShots : approvedShots
				
				if !cyclePool.isEmpty {
					let clusters = audioSequence.clusters
					let activeClusterIdx: Int
					if clusters.isEmpty {
						activeClusterIdx = 0
					} else if let idx = clusters.firstIndex(where: { mid >= $0.startTime && mid <= $0.endTime }) {
						activeClusterIdx = idx
					} else {
						// Find the closest preceding cluster
						var lastPrecedingIdx = 0
						for (idx, cluster) in clusters.enumerated() {
							if cluster.endTime <= mid {
								lastPrecedingIdx = idx
							} else {
								break
							}
						}
						activeClusterIdx = lastPrecedingIdx
					}
					
					let shotIdx = activeClusterIdx % cyclePool.count
					activeShot = cyclePool[shotIdx]
				}
			}
			
			guard let shot = activeShot else {
				frames.append(nil)
				currentSpeechFrameCount = 0
				continue
			}
			
			// Check talking status
			let isSpeaking = audioSequence.segments.first { mid >= $0.startTime && mid <= $0.endTime }?.isSpeech ?? false
			
			// Check mouth open/closed based on speech cluster logic:
			// "4 aperte e 2 chiuse... sempre quando c'è parlato"
			let mouthOpen: Bool
			if isSpeaking {
				let patternIndex = currentSpeechFrameCount % 6
				mouthOpen = (patternIndex >= 0 && patternIndex <= 3)
				currentSpeechFrameCount += 1
			} else {
				mouthOpen = false
				currentSpeechFrameCount = 0
			}
			
			// Check blinking status (regular cycle + deterministic 1% random blink chance per frame)
			let relativeInCycle = mid.truncatingRemainder (dividingBy: blinkCycle)
			var isBlinking = relativeInCycle >= 2.0 && relativeInCycle < 2.15
			
			if !isBlinking {
				let seed = sin (Double (k)) * 10000.0
				let randomValue = abs (seed - floor (seed))
				if randomValue < 0.01 {
					isBlinking = true
				}
			}
			
			// Select variant
			let variant: THFrameVariant
			if isBlinking {
				variant = mouthOpen ? .mouthOpenEyesClosed : .mouthClosedEyesClosed
			} else {
				variant = mouthOpen ? .mouthOpenEyesOpen : .mouthClosedEyesOpen
			}
			
			guard let relativePath = shot.variants.imagePath (for: variant) ?? shot.variants.mouthClosedEyesOpen else {
				frames.append(nil)
				continue
			}
			
			let imageURL = THFileUtils.resolveAssetPath (relativePath, projectURL: projectURL)
			
			// Calculate and cache scale factor (using CGImageSource to avoid loading image data into RAM)
			let scaleFactor: CGFloat
			if let cached = scaleFactorCache[imageURL] {
				scaleFactor = cached
			} else {
				var calculatedScale: CGFloat = 1.0
				if let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
				   let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [CFString: Any],
				   let imgWidth = imageProperties[kCGImagePropertyPixelWidth] as? CGFloat,
				   let imgHeight = imageProperties[kCGImagePropertyPixelHeight] as? CGFloat {
					if imgWidth > 0 && imgHeight > 0 {
						if imgWidth < resolution.width || imgHeight < resolution.height {
							calculatedScale = max(resolution.width / imgWidth, resolution.height / imgHeight)
						}
					}
				}
				scaleFactorCache[imageURL] = calculatedScale
				scaleFactor = calculatedScale
			}
			
			frames.append(FrameInfo(shot: shot, variant: variant, imageURL: imageURL, scaleFactor: scaleFactor))
		}
		
		// 4. Create image layers for the timeline by merging consecutive identical frames
		var sources: [UMVCSource] = []
		var currentSpanStart = 0
		
		while currentSpanStart < totalFrames {
			guard let startFrame = frames[currentSpanStart] else {
				currentSpanStart += 1
				continue
			}
			
			var currentSpanEnd = currentSpanStart + 1
			while currentSpanEnd < totalFrames {
				if let nextFrame = frames[currentSpanEnd],
				   nextFrame.imageURL == startFrame.imageURL,
				   nextFrame.scaleFactor == startFrame.scaleFactor {
					currentSpanEnd += 1
				} else {
					break
				}
			}
			
			let start = Double(currentSpanStart) * frameDuration
			let end = Double(currentSpanEnd) * frameDuration
			let segmentDuration = end - start
			let scaleFactor = startFrame.scaleFactor
			
			// Opacity keyframes: fully visible from start until 0.001s before end, then immediately invisible (0 opacity)
			let kStart = UMVCKeyframe (time: 0.0, transform: UMVCTransform (position: .zero, scale: scaleFactor, rotation: 0.0, opacity: 1.0))
			let kEndPre = UMVCKeyframe (time: segmentDuration - 0.001, transform: UMVCTransform (position: .zero, scale: scaleFactor, rotation: 0.0, opacity: 1.0))
			let kEnd = UMVCKeyframe (time: segmentDuration, transform: UMVCTransform (position: .zero, scale: scaleFactor, rotation: 0.0, opacity: 0.0))
			
			let source = UMVCSource (
				id: UUID (),
				type: .image,
				sourceUrl: startFrame.imageURL,
				startTime: start,
				keyframeList: [kStart, kEndPre, kEnd]
			)
			sources.append (source)
			
			currentSpanStart = currentSpanEnd
		}
		
		// 5. Add scene audio file as a media track source (starts at time 0)
		let audioURL = THFileUtils.resolveAssetPath (audioSequence.audioFilePath, projectURL: projectURL)
		let audioSource = UMVCSource (
			id: UUID (),
			type: .video,
			sourceUrl: audioURL,
			startTime: 0.0,
			keyframeList: [
				UMVCKeyframe (time: 0.0, transform: UMVCTransform (position: .zero, scale: 1.0, rotation: 0.0, opacity: 0.0))
			]
		)
		sources.append (audioSource)
		
		// 6. Setup timeline settings
		let outputSettings = UMVCOutputSettings (
			format: .h264,
			videoDataRate: 6_000_000,
			audioDataRate: 192_000
		)
		let timelineSettings = UMVCTimelineSettings (
			fps: 30.0,
			resolution: resolution,
			outputSettings: outputSettings
		)
		
		let timeline = UMVCTimeline (
			sourceList: sources,
			settings: timelineSettings
		)
		
		// 7. Compose final video using UMVideoComposer
		let composer = UMVideoComposer ()
		try await composer.composeVideo (from: timeline, to: outputURL, progress: progress)
		
		return "renders/\(outputFilename)"
	}
}
