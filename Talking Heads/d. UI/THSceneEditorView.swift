//
//  THSceneEditorView.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import SwiftUI
import UniformTypeIdentifiers
import UMUIControls
import AVFoundation
import FluidAudio

// MARK: - Scene Editor View

/// Detail view for editing a scene's pipeline state.
/// Shows the current pipeline progress and provides controls for each step:
/// 1. Audio Import → 2. Analysis → 3. Transcription → 4. Shots → 5. Render
struct THSceneEditorView: View {
	@Binding var scene: THScene
	@Binding var document: Talking_HeadsDocument

	@State private var isImportingAudio = false
	@State private var isGeneratingImages = false
	@State private var generationProgress: Double = 0.0
	@State private var generationStatus = ""
	@State private var generationError: String?

	@State private var isAnalyzingAudio = false
	@State private var analysisStatus = ""

	var body: some View {
		ScrollView {
			VStack (alignment: .leading, spacing: 20) {
				apiKeyWarningBanner
				headerSection
				sceneInfoSection
				audioPipelineSection
				transcriptSection
				shotPoolSection
				renderSection
			}
			.padding (24)
		}
		.navigationTitle (scene.name)
		.fileImporter (
			isPresented: $isImportingAudio,
			allowedContentTypes: [.audio],
			allowsMultipleSelection: false
		) { result in
			handleAudioImport (result)
		}
		.overlay {
			if isGeneratingImages {
				ZStack {
					Color.black.opacity (0.4)
						.ignoresSafeArea ()
					
					VStack (spacing: 16) {
						ProgressView (value: generationProgress, total: 4.0) {
							Text (generationStatus)
								.font (.headline)
						} currentValueLabel: {
							Text ("\(Int(generationProgress))/4 variants generated")
						}
						.progressViewStyle (.linear)
						.frame (width: 300)
						
						Text ("Please keep the application open. Enforcing rate-limits between API requests...")
							.font (.caption)
							.foregroundStyle (.secondary)
							.multilineTextAlignment (.center)
					}
					.padding (24)
					.background (.background)
					.clipShape (RoundedRectangle (cornerRadius: 16))
					.shadow (radius: 10)
				}
			} else if isAnalyzingAudio {
				ZStack {
					Color.black.opacity (0.4)
						.ignoresSafeArea ()
					
					VStack (spacing: 16) {
						ProgressView ()
							.progressViewStyle (.circular)
						
						Text (analysisStatus)
							.font (.headline)
						
						Text ("Analyzing audio file with CoreML Silero VAD...")
							.font (.caption)
							.foregroundStyle (.secondary)
					}
					.padding (24)
					.background (.background)
					.clipShape (RoundedRectangle (cornerRadius: 16))
					.shadow (radius: 10)
				}
			}
		}
		.alert ("Generation Failed", isPresented: Binding<Bool>(
			get: { generationError != nil },
			set: { _ in generationError = nil }
		)) {
			Button ("OK") {}
		} message: {
			if let error = generationError {
				Text (error)
			}
		}
	}

	// MARK: - API Key Banner

	@ViewBuilder
	private var apiKeyWarningBanner: some View {
		if !THImageGenerator.hasApiKey {
			HStack {
				Image (systemName: "exclamationmark.triangle.fill")
					.foregroundStyle (.orange)
				Text ("Gemini API key is missing. Set it in Application Settings (Preferences).")
					.font (.subheadline)
				Spacer ()
				Button ("Open Settings") {
					NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
				}
				.controlSize (.small)
			}
			.padding (10)
			.background (Color.orange.opacity (0.1))
			.clipShape (RoundedRectangle (cornerRadius: 8))
		}
	}

	// MARK: - Header

	private var headerSection: some View {
		VStack (alignment: .leading, spacing: 8) {
			HStack {
				Text ("Scene Editor")
					.font (.title2.bold ())
				Spacer ()
				pipelineProgressBadge
			}
			Text ("Import audio and configure the video generation pipeline")
				.font (.subheadline)
				.foregroundStyle (.secondary)
		}
	}

	// MARK: - Scene Info

	private var sceneInfoSection: some View {
		UMUISection ("Scene Configuration") {
			VStack (alignment: .leading, spacing: 12) {
				THEditorField (label: "Scene Name", text: $scene.name)

				HStack (spacing: 20) {
					VStack (alignment: .leading, spacing: 4) {
						Text ("Character")
							.font (.caption)
							.foregroundStyle (.secondary)
						if let character = document.projectState.characters.first (where: { $0.id == scene.characterId }) {
							Label (character.name, systemImage: "person.fill")
								.font (.body)
						} else {
							Text ("Missing character")
								.font (.body)
								.foregroundStyle (.red)
						}
					}

					VStack (alignment: .leading, spacing: 4) {
						Text ("Environment")
							.font (.caption)
							.foregroundStyle (.secondary)
						if let environment = document.projectState.environments.first (where: { $0.id == scene.environmentId }) {
							Label (environment.name, systemImage: "photo")
								.font (.body)
						} else {
							Text ("Missing environment")
								.font (.body)
								.foregroundStyle (.red)
						}
					}

					VStack (alignment: .leading, spacing: 4) {
						Text ("Aspect Ratio")
							.font (.caption)
							.foregroundStyle (.secondary)
						Picker ("Aspect Ratio", selection: $scene.aspectRatio) {
							ForEach (THAspectRatio.allCases) { ratio in
								Text (ratio.displayName).tag (ratio)
							}
						}
						.labelsHidden ()
					}
				}
				
				THEditorField (label: "Character Position in Environment", text: $scene.characterPosition, axis: .vertical)
				THEditorField (label: "Camera Setup", text: $scene.cameraSetup, axis: .vertical)
			}
		}
	}

	// MARK: - Audio Pipeline

	private var audioPipelineSection: some View {
		UMUISection ("Step 1: Audio") {
			VStack (alignment: .leading, spacing: 12) {
				if let audioSeq = scene.audioSequence {
					// Audio loaded
					HStack {
						Image (systemName: "checkmark.circle.fill")
							.foregroundStyle (.green)
						Text ("Audio loaded")
							.font (.body)
						Spacer ()
						Text (formatDuration (audioSeq.duration))
							.font (.system (.body, design: .monospaced))
							.foregroundStyle (.secondary)
					}

					HStack (spacing: 16) {
						VStack (alignment: .leading) {
							Text ("Segments")
								.font (.caption)
								.foregroundStyle (.secondary)
							Text ("\(audioSeq.segments.count)")
								.font (.title3.bold ())
						}
						VStack (alignment: .leading) {
							Text ("Speech Clusters")
								.font (.caption)
								.foregroundStyle (.secondary)
							Text ("\(audioSeq.clusters.count)")
								.font (.title3.bold ())
						}
					}

					Button {
						isImportingAudio = true
					} label: {
						Label ("Replace Audio", systemImage: "arrow.triangle.2.circlepath")
					}
					.controlSize (.small)
				} else {
					// No audio yet
					HStack {
						Image (systemName: "waveform")
							.foregroundStyle (.quaternary)
						Text ("No audio file imported")
							.foregroundStyle (.secondary)
					}

					Button {
						isImportingAudio = true
					} label: {
						Label ("Import Audio", systemImage: "square.and.arrow.down")
					}
					.buttonStyle (.borderedProminent)
					.controlSize (.small)
				}
			}
		}
	}

	// MARK: - Transcript

	private var transcriptSection: some View {
		UMUISection ("Step 2: Transcription") {
			VStack (alignment: .leading, spacing: 12) {
				if let transcript = scene.transcript {
					HStack {
						Image (systemName: "checkmark.circle.fill")
							.foregroundStyle (.green)
						Text ("\(transcript.sentences.count) sentences")
							.font (.body)
						Spacer ()
						Text ("\(transcript.shotChangeCount) shot changes")
							.font (.caption)
							.foregroundStyle (.secondary)
					}

					if !transcript.fullText.isEmpty {
						Text (transcript.fullText)
							.font (.caption)
							.foregroundStyle (.secondary)
							.lineLimit (4)
							.padding (8)
							.frame (maxWidth: .infinity, alignment: .leading)
							.background (Color.primary.opacity (0.04))
							.clipShape (RoundedRectangle (cornerRadius: 6))
					}
				} else {
					HStack {
						Image (systemName: "text.alignleft")
							.foregroundStyle (.quaternary)
						Text (scene.audioSequence != nil
							? "Ready to transcribe"
							: "Import audio first")
							.foregroundStyle (.secondary)
					}

					if scene.audioSequence != nil {
						Button {
							// Phase 3: THAudioAnalyzer will handle this
						} label: {
							Label ("Run Transcription", systemImage: "play.fill")
						}
						.buttonStyle (.borderedProminent)
						.controlSize (.small)
						.disabled (true) // Enabled in Slice 2
					}
				}
			}
		}
	}

	// MARK: - Shot Pool

	private var shotPoolSection: some View {
		UMUISection ("Step 3: Shot Pool") {
			VStack (alignment: .leading, spacing: 12) {
				let sceneShots = document.projectState.shots.filter { scene.shotIds.contains ($0.id) }
				let approvedCount = sceneShots.filter { $0.isApproved }.count

				if sceneShots.isEmpty {
					HStack {
						Image (systemName: "camera")
							.foregroundStyle (.quaternary)
						Text ("No shots generated yet")
							.foregroundStyle (.secondary)
					}

					Button {
						generateShots ()
					} label: {
						Label ("Generate Shots", systemImage: "sparkles")
					}
					.buttonStyle (.borderedProminent)
					.controlSize (.small)
					.disabled (!THImageGenerator.hasApiKey)
				} else {
					HStack {
						Image (systemName: "checkmark.circle.fill")
							.foregroundStyle (approvedCount > 0 ? .green : .orange)
						Text ("\(sceneShots.count) shots (\(approvedCount) approved)")
							.font (.body)
					}
					
					let projectURL = NSDocumentController.shared.currentDocument?.fileURL
					
					THShotGalleryView (
						shots: sceneShots,
						projectURL: projectURL,
						onApprove: { shotId, isApproved in
							if let idx = document.projectState.shots.firstIndex (where: { $0.id == shotId }) {
								document.projectState.shots [idx].isApproved = isApproved
								scene.modifiedAt = Date ()
							}
						},
						onDelete: { shotId in
							scene.shotIds.removeAll { $0 == shotId }
							document.projectState.shots.removeAll { $0.id == shotId }
							scene.modifiedAt = Date ()
						}
					)
					.frame (minHeight: 220)
					
					HStack {
						Button {
							generateShots ()
						} label: {
							Label ("Generate More Shots", systemImage: "sparkles")
						}
						.controlSize (.small)
						.disabled (!THImageGenerator.hasApiKey)
					}
				}
			}
		}
	}

	// MARK: - Render

	private var renderSection: some View {
		UMUISection ("Step 4: Render") {
			VStack (alignment: .leading, spacing: 12) {
				if let renderPath = scene.renderedVideoPath {
					HStack {
						Image (systemName: "checkmark.circle.fill")
							.foregroundStyle (.green)
						Text ("Video rendered")
							.font (.body)
						Spacer ()
						Text (renderPath)
							.font (.caption)
							.foregroundStyle (.secondary)
							.lineLimit (1)
					}
				} else {
					HStack {
						Image (systemName: "film")
							.foregroundStyle (.quaternary)
						Text ("Not rendered yet")
							.foregroundStyle (.secondary)
					}

					Button {
						// Phase 4: THVideoRenderer will handle this
					} label: {
						Label ("Render Video", systemImage: "play.rectangle.fill")
					}
					.buttonStyle (.borderedProminent)
					.controlSize (.small)
					.disabled (true) // Enabled in Slice 4
				}
			}
		}
	}

	// MARK: - Pipeline Progress Badge

	private var pipelineProgressBadge: some View {
		let completedSteps = [
			scene.audioSequence != nil,
			scene.transcript != nil,
			!scene.shotIds.isEmpty,
			scene.renderedVideoPath != nil
		].filter { $0 }.count

		return Text ("\(completedSteps)/4")
			.font (.caption.bold ())
			.foregroundStyle (.white)
			.padding (.horizontal, 8)
			.padding (.vertical, 4)
			.background (
				Capsule ()
					.fill (completedSteps == 4 ? .green : .orange)
			)
	}

	// MARK: - Helpers

	private func formatDuration (_ seconds: Double) -> String {
		let minutes = Int (seconds) / 60
		let secs = Int (seconds) % 60
		return String (format: "%02d:%02d", minutes, secs)
	}

	private func handleAudioImport (_ result: Result<[URL], Error>) {
		guard case .success (let urls) = result,
			  let url = urls.first else { return }
		
		guard let currentDoc = NSDocumentController.shared.currentDocument,
			  let projectURL = currentDoc.fileURL else {
			// Save the project file first to have a valid path
			return
		}
		
		let gotAccess = url.startAccessingSecurityScopedResource ()
		
		isAnalyzingAudio = true
		analysisStatus = "Importing audio file..."
		
		Task {
			defer {
				if gotAccess {
					url.stopAccessingSecurityScopedResource ()
				}
			}
			
			do {
				// Copy the audio file into the project bundle folder 'audio'
				let relativePath = try THFileUtils.copyIntoProject (source: url, subdirectory: "audio", projectURL: projectURL)
				
				// Resolve the copied absolute path to extract duration
				let destURL = THFileUtils.resolveAssetPath (relativePath, projectURL: projectURL)
				let asset = AVURLAsset (url: destURL)
				let durationCMTime = try await asset.load (.duration)
				let seconds = CMTimeGetSeconds (durationCMTime)
				let duration = seconds.isNaN ? 0.0 : seconds
				
				// 1. Resample audio
				await MainActor.run {
					analysisStatus = "Resampling audio to 16kHz..."
				}
				let converter = AudioConverter ()
				let samples = try converter.resampleAudioFile (destURL)
				
				// 2. Initialize VadManager
				await MainActor.run {
					analysisStatus = "Initializing VAD Model..."
				}
				let vadManager = try await VadManager ()
				
				// 3. Process VAD
				await MainActor.run {
					analysisStatus = "Running Voice Activity Detection..."
				}
				let vadResults = try await vadManager.process (samples)
				
				// 4. Segment Speech
				await MainActor.run {
					analysisStatus = "Segmenting speech clusters..."
				}
				let segments = await vadManager.segmentSpeech (from: vadResults, totalSamples: samples.count)
				
				// Map FluidAudio's VadResult/VadSegment to our THAudioSegment and THSpeechCluster
				var thSegments: [THAudioSegment] = []
				for (index, res) in vadResults.enumerated () {
					let startTime = Double (index * VadManager.chunkSize) / Double (VadManager.sampleRate)
					let endTime = Double ((index + 1) * VadManager.chunkSize) / Double (VadManager.sampleRate)
					let thSeg = THAudioSegment (
						startTime: startTime,
						endTime: min (endTime, duration),
						isSpeech: res.isVoiceActive
					)
					thSegments.append (thSeg)
				}
				
				var thClusters: [THSpeechCluster] = []
				for seg in segments {
					let clusterSegments = thSegments.filter {
						$0.startTime >= seg.startTime && $0.endTime <= seg.endTime
					}
					let cluster = THSpeechCluster (
						startTime: seg.startTime,
						endTime: min (seg.endTime, duration),
						segments: clusterSegments
					)
					thClusters.append (cluster)
				}
				
				await MainActor.run {
					scene.audioSequence = THAudioSequence (
						audioFilePath: relativePath,
						duration: duration,
						segments: thSegments,
						clusters: thClusters
					)
					scene.transcript = nil
					scene.shotAssignments = []
					scene.renderedVideoPath = nil
					scene.modifiedAt = Date ()
					isAnalyzingAudio = false
				}
			} catch {
				await MainActor.run {
					print ("Audio analysis failed: \(error.localizedDescription)")
					isAnalyzingAudio = false
				}
			}
		}
	}
	
	private func generateShots () {
		guard let character = document.projectState.characters.first (where: { $0.id == scene.characterId }),
			  let environment = document.projectState.environments.first (where: { $0.id == scene.environmentId })
		else { return }
		
		isGeneratingImages = true
		generationProgress = 0.0
		generationStatus = "Initializing AI Image Models..."
		generationError = nil
		
		Task {
			do {
				// We'll generate shots inside the temporary working directory of this document bundle
				// We can obtain the package path if we are sandbox-compliant.
				// For the UI, we retrieve the fileURL through NSDocument.
				// Since we do not have direct document URL in fileWrapper easily, we can find it
				// through NSDocumentController shared.
				guard let currentDoc = NSDocumentController.shared.currentDocument,
					  let projectURL = currentDoc.fileURL else {
					throw NSError (domain: "THSceneEditorView", code: 404, userInfo: [NSLocalizedDescriptionKey: "Save the project file first before generating shots."])
				}
				
				let generator = THImageGenerator ()
				
				// Generate 1 shot with 4 variants for demonstration
				let newVariants = try await generator.generateVariants (
					for: character,
					in: environment,
					shotType: .mediumCloseUp,
					aspectRatio: scene.aspectRatio,
					characterPosition: scene.characterPosition,
					cameraSetup: scene.cameraSetup,
					projectURL: projectURL
				) { step in
					Task { @MainActor in
						self.generationProgress = Double (step)
						switch step {
						case 1:
							self.generationStatus = "Generated Base Pose (Neutrale)..."
						case 2:
							self.generationStatus = "Generated Variant 2 (Bocca Aperta)..."
						case 3:
							self.generationStatus = "Generated Variant 3 (Occhi Chiusi)..."
						case 4:
							self.generationStatus = "Generated Variant 4 (Mouth Open / Eyes Closed)..."
						default:
							break
						}
					}
				}
				
				await MainActor.run {
					let newShot = THShot (
						characterId: character.id,
						environmentId: environment.id,
						shotType: .mediumCloseUp,
						promptUsed: "Generated using UMGeminiLib NanoBananaPro",
						variants: newVariants,
						isApproved: true
					)
					
					document.projectState.shots.append (newShot)
					scene.shotIds.append (newShot.id)
					isGeneratingImages = false
				}
				
			} catch {
				await MainActor.run {
					self.generationError = error.localizedDescription
					self.isGeneratingImages = false
				}
			}
		}
	}
}
