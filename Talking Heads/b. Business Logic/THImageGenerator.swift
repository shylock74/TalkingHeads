//
//  THImageGenerator.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation
import CoreImage
import UMGeminiLib
import SwiftUI

/// Generates character images using UMGeminiLib.
actor THImageGenerator {
	
	/// Helper to get the saved Gemini API Key from UserDefaults. Binds to UI Preferences.
	nonisolated static var savedApiKey: String {
		UserDefaults.standard.string (forKey: "UMGeminiAPIKey") ?? ""
	}
	
	/// Checks if the API key is configured.
	nonisolated static var hasApiKey: Bool {
		!savedApiKey.trimmingCharacters (in: .whitespacesAndNewlines).isEmpty
	}
	
	/// Generates only the base variant (Variant 1: Mouth Closed, Eyes Open) for a character in an environment.
	/// - Returns: The relative path of the generated base variant image file.
	func generateBaseVariant (
		for character: THCharacter,
		in environment: THEnvironment,
		shotType: THShotType,
		aspectRatio: THAspectRatio,
		characterPosition: String = "",
		cameraSetup: String = "",
		projectURL: URL
	) async throws -> String {
		
		let apiKey = Self.savedApiKey
		guard !apiKey.isEmpty else {
			throw NSError (domain: "THImageGenerator", code: 401, userInfo: [NSLocalizedDescriptionKey: "Gemini API key is not configured. Please set it in Settings."])
		}
		
		// Map aspect ratio enum to UMGeminiLite.AspectRatio
		let geminiRatio = UMGeminiLite.AspectRatio (ratioString: aspectRatio.rawValue) ?? .ar_16_9
		
		// Initialize the wrapper
		var gemini = UMGeminiLite (apiKey: apiKey)
		gemini.imageModel = .nanoBananaPro
		
		let fm = FileManager.default
		let shotsDir = projectURL.appendingPathComponent ("shots")
		if !fm.fileExists (atPath: shotsDir.path) {
			try fm.createDirectory (at: shotsDir, withIntermediateDirectories: true)
		}
		
		// Load reference images for the character and environment
		print("[THImageGenerator] --- Loading Reference Images ---")
		print("[THImageGenerator] Project URL: \(projectURL.path)")
		var referenceCIImages: [CIImage] = []
		
		print("[THImageGenerator] Character '\(character.name)' has \(character.referenceImagePaths.count) reference paths:")
		for path in character.referenceImagePaths {
			let fileURL = path.hasPrefix ("/") ? URL (fileURLWithPath: path) : THFileUtils.resolveAssetPath (path, projectURL: projectURL)
			let exists = fm.fileExists (atPath: fileURL.path)
			print("  Path: '\(path)' -> Resolved URL: '\(fileURL.path)' -> Exists on disk? \(exists)")
			if exists {
				if let ciImage = CIImage (contentsOf: fileURL) {
					referenceCIImages.append (ciImage)
					print("    Successfully loaded CIImage from '\(fileURL.lastPathComponent)'")
				} else {
					print("    FAILED to load CIImage from '\(fileURL.lastPathComponent)'")
				}
			}
		}
		
		print("[THImageGenerator] Environment '\(environment.name)' has \(environment.referenceImagePaths.count) reference paths:")
		for path in environment.referenceImagePaths {
			let fileURL = path.hasPrefix ("/") ? URL (fileURLWithPath: path) : THFileUtils.resolveAssetPath (path, projectURL: projectURL)
			let exists = fm.fileExists (atPath: fileURL.path)
			print("  Path: '\(path)' -> Resolved URL: '\(fileURL.path)' -> Exists on disk? \(exists)")
			if exists {
				if let ciImage = CIImage (contentsOf: fileURL) {
					referenceCIImages.append (ciImage)
					print("    Successfully loaded CIImage from '\(fileURL.lastPathComponent)'")
				} else {
					print("    FAILED to load CIImage from '\(fileURL.lastPathComponent)'")
				}
			}
		}
		print("[THImageGenerator] Total Reference CIImages loaded: \(referenceCIImages.count)")
		print("[THImageGenerator] ---------------------------------")
		
		// Generate Variant 1: Mouth Closed, Eyes Open (Base Shot)
		let prompt1 = THPromptEngine.buildPrompt (
			for: character,
			in: environment,
			shotType: shotType,
			variant: .mouthClosedEyesOpen,
			characterPosition: characterPosition,
			cameraSetup: cameraSetup
		)
		
		let baseCIImage = try await gemini.generateImageWithNanoBanana (
			model: gemini.imageModel,
			textPrompt: prompt1,
			with: referenceCIImages,
			aspectRatio: geminiRatio
		)
		
		let baseFilename = THFileUtils.uniqueFilename (from: "\(character.name.replacingOccurrences(of: " ", with: "_"))_\(shotType.rawValue)_v1.png")
		let baseFileURL = shotsDir.appendingPathComponent (baseFilename)
		try saveCIImage (baseCIImage, to: baseFileURL)
		return "shots/\(baseFilename)"
	}
	
	/// Generates the remaining three variants based on the base image.
	/// - Returns: The complete set of 4 variants.
	func generateRemainingVariants (
		baseImagePath: String,
		for character: THCharacter,
		in environment: THEnvironment,
		shotType: THShotType,
		aspectRatio: THAspectRatio,
		characterPosition: String = "",
		cameraSetup: String = "",
		projectURL: URL,
		progress: (@Sendable (Int) -> Void)? = nil
	) async throws -> THShotVariants {
		
		let apiKey = Self.savedApiKey
		guard !apiKey.isEmpty else {
			throw NSError (domain: "THImageGenerator", code: 401, userInfo: [NSLocalizedDescriptionKey: "Gemini API key is not configured. Please set it in Settings."])
		}
		
		let geminiRatio = UMGeminiLite.AspectRatio (ratioString: aspectRatio.rawValue) ?? .ar_16_9
		var gemini = UMGeminiLite (apiKey: apiKey)
		gemini.imageModel = .nanoBanana2
		
		let fm = FileManager.default
		let shotsDir = projectURL.appendingPathComponent ("shots")
		
		// Load the base image
		let baseFileURL = THFileUtils.resolveAssetPath (baseImagePath, projectURL: projectURL)
		guard fm.fileExists (atPath: baseFileURL.path),
			  let baseCIImage = CIImage (contentsOf: baseFileURL) else {
			throw NSError (domain: "THImageGenerator", code: 404, userInfo: [NSLocalizedDescriptionKey: "Base shot image file not found."])
		}

		// Load reference images for the character and environment
		print("[THImageGenerator] --- Loading Reference Images for Variants ---")
		var referenceCIImages: [CIImage] = []
		
		print("[THImageGenerator] Character '\(character.name)' has \(character.referenceImagePaths.count) reference paths:")
		for path in character.referenceImagePaths {
			let fileURL = path.hasPrefix ("/") ? URL (fileURLWithPath: path) : THFileUtils.resolveAssetPath (path, projectURL: projectURL)
			let exists = fm.fileExists (atPath: fileURL.path)
			if exists {
				if let ciImage = CIImage (contentsOf: fileURL) {
					referenceCIImages.append (ciImage)
					print("    Successfully loaded CIImage from '\(fileURL.lastPathComponent)'")
				} else {
					print("    FAILED to load CIImage from '\(fileURL.lastPathComponent)'")
				}
			}
		}
		
		print("[THImageGenerator] Environment '\(environment.name)' has \(environment.referenceImagePaths.count) reference paths:")
		for path in environment.referenceImagePaths {
			let fileURL = path.hasPrefix ("/") ? URL (fileURLWithPath: path) : THFileUtils.resolveAssetPath (path, projectURL: projectURL)
			let exists = fm.fileExists (atPath: fileURL.path)
			if exists {
				if let ciImage = CIImage (contentsOf: fileURL) {
					referenceCIImages.append (ciImage)
					print("    Successfully loaded CIImage from '\(fileURL.lastPathComponent)'")
				} else {
					print("    FAILED to load CIImage from '\(fileURL.lastPathComponent)'")
				}
			}
		}
		print("[THImageGenerator] Total Reference CIImages loaded for variants: \(referenceCIImages.count)")
		print("[THImageGenerator] ---------------------------------------------")
		
		// Helper to generate a variant relative to the base image
		let generateRelativeVariant = { (variant: THFrameVariant, suffix: String) async throws -> String in
			let prompt = THPromptEngine.buildPrompt (
				for: character,
				in: environment,
				shotType: shotType,
				variant: variant,
				characterPosition: characterPosition,
				cameraSetup: cameraSetup
			)
			
			let variantCIImage = try await gemini.generateImageWithNanoBanana (
				model: gemini.imageModel,
				textPrompt: prompt,
				with: referenceCIImages + [baseCIImage],
				aspectRatio: geminiRatio
			)
			
			let filename = THFileUtils.uniqueFilename (from: "\(character.name.replacingOccurrences(of: " ", with: "_"))_\(shotType.rawValue)_\(suffix).png")
			let fileURL = shotsDir.appendingPathComponent (filename)
			try self.saveCIImage (variantCIImage, to: fileURL)
			return "shots/\(filename)"
		}
		
		// 1. Variant 2: Mouth Open, Eyes Open
		progress? (1)
		let relativePath2 = try await generateRelativeVariant (.mouthOpenEyesOpen, "v2")
		await UMGeminiLite.delayRequest ()
		
		// 2. Variant 3: Mouth Closed, Eyes Closed
		progress? (2)
		let relativePath3 = try await generateRelativeVariant (.mouthClosedEyesClosed, "v3")
		await UMGeminiLite.delayRequest ()
		
		// 3. Variant 4: Mouth Open, Eyes Closed
		progress? (3)
		let relativePath4 = try await generateRelativeVariant (.mouthOpenEyesClosed, "v4")
		
		return THShotVariants (
			mouthClosedEyesOpen: baseImagePath,
			mouthOpenEyesOpen: relativePath2,
			mouthClosedEyesClosed: relativePath3,
			mouthOpenEyesClosed: relativePath4
		)
	}

	/// Generates all 4 variants at once (legacy/chain helper).
	func generateVariants (
		for character: THCharacter,
		in environment: THEnvironment,
		shotType: THShotType,
		aspectRatio: THAspectRatio,
		characterPosition: String = "",
		cameraSetup: String = "",
		projectURL: URL,
		progress: (@Sendable (Int) -> Void)? = nil
	) async throws -> THShotVariants {
		let basePath = try await generateBaseVariant (
			for: character,
			in: environment,
			shotType: shotType,
			aspectRatio: aspectRatio,
			characterPosition: characterPosition,
			cameraSetup: cameraSetup,
			projectURL: projectURL
		)
		progress? (1)
		await UMGeminiLite.delayRequest ()
		
		return try await generateRemainingVariants (
			baseImagePath: basePath,
			for: character,
			in: environment,
			shotType: shotType,
			aspectRatio: aspectRatio,
			characterPosition: characterPosition,
			cameraSetup: cameraSetup,
			projectURL: projectURL
		) { step in
			progress? (step + 1)
		}
	}
	
	/// Helper to write a CIImage as a PNG file.
	private func saveCIImage (_ image: CIImage, to url: URL) throws {
		let ctx = CIContext ()
		let colorSpace = image.colorSpace ?? CGColorSpaceCreateDeviceRGB ()
		guard let pngData = ctx.pngRepresentation (of: image, format: .RGBA8, colorSpace: colorSpace, options: [:]) else {
			throw NSError (domain: "THImageGenerator", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to convert CIImage to PNG data"])
		}
		try pngData.write (to: url)
	}
}
