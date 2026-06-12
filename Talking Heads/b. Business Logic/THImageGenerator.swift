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
	
	/// Generates a set of 4 animatable variants for a shot.
	/// - Parameters:
	///   - character: The character target.
	///   - environment: The environment backdrop.
	///   - shotType: The framing type.
	///   - aspectRatio: The aspect ratio for the sequence.
	///   - projectURL: Absolute URL of the .thproject directory bundle.
	///   - progress: Optional callback for reporting completion of each variant (1 to 4).
	/// - Returns: The generated THShotVariants containing relative image file paths.
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
		
		let apiKey = Self.savedApiKey
		guard !apiKey.isEmpty else {
			throw NSError (domain: "THImageGenerator", code: 401, userInfo: [NSLocalizedDescriptionKey: "Gemini API key is not configured. Please set it in Settings."])
		}
		
		// Map aspect ratio enum to UMGeminiLite.AspectRatio
		let geminiRatio = UMGeminiLite.AspectRatio (ratioString: aspectRatio.rawValue) ?? .ar_16_9
		
		// Initialize the wrapper
		var gemini = UMGeminiLite (apiKey: apiKey)
		gemini.imageModel = .nanoBananaPro // Using nanoBananaPro which is referenceable (supports Image-to-Image)
		
		let fm = FileManager.default
		let shotsDir = projectURL.appendingPathComponent ("shots")
		if !fm.fileExists (atPath: shotsDir.path) {
			try fm.createDirectory (at: shotsDir, withIntermediateDirectories: true)
		}
		
		// 1. Generate Variant 1: Mouth Closed, Eyes Open (Base Shot) via Text-to-Image
		let prompt1 = THPromptEngine.buildPrompt (
			for: character,
			in: environment,
			shotType: shotType,
			variant: .mouthClosedEyesOpen,
			characterPosition: characterPosition,
			cameraSetup: cameraSetup
		)
		
		// We use generateImageWithNanoBanana which generates and returns a CIImage
		let baseCIImage = try await gemini.generateImageWithNanoBanana (
			model: gemini.imageModel,
			textPrompt: prompt1,
			with: [], // Empty since it's the first base image
			aspectRatio: geminiRatio
		)
		
		let baseFilename = THFileUtils.uniqueFilename (from: "\(character.name.replacingOccurrences(of: " ", with: "_"))_\(shotType.rawValue)_v1.png")
		let baseFileURL = shotsDir.appendingPathComponent (baseFilename)
		try saveCIImage (baseCIImage, to: baseFileURL)
		let relativePath1 = "shots/\(baseFilename)"
		progress? (1)
		
		// Enforce rate limits gap between API requests
		await UMGeminiLite.delayRequest ()
		
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
			
			// We pass baseCIImage inside `with` to do Image-to-Image reference generation
			let variantCIImage = try await gemini.generateImageWithNanoBanana (
				model: gemini.imageModel,
				textPrompt: prompt,
				with: [baseCIImage],
				aspectRatio: geminiRatio
			)
			
			let filename = THFileUtils.uniqueFilename (from: "\(character.name.replacingOccurrences(of: " ", with: "_"))_\(shotType.rawValue)_\(suffix).png")
			let fileURL = shotsDir.appendingPathComponent (filename)
			try self.saveCIImage (variantCIImage, to: fileURL)
			return "shots/\(filename)"
		}
		
		// 2. Variant 2: Mouth Open, Eyes Open
		let relativePath2 = try await generateRelativeVariant (.mouthOpenEyesOpen, "v2")
		progress? (2)
		await UMGeminiLite.delayRequest ()
		
		// 3. Variant 3: Mouth Closed, Eyes Closed
		let relativePath3 = try await generateRelativeVariant (.mouthClosedEyesClosed, "v3")
		progress? (3)
		await UMGeminiLite.delayRequest ()
		
		// 4. Variant 4: Mouth Open, Eyes Closed
		let relativePath4 = try await generateRelativeVariant (.mouthOpenEyesClosed, "v4")
		progress? (4)
		
		return THShotVariants (
			mouthClosedEyesOpen: relativePath1,
			mouthOpenEyesOpen: relativePath2,
			mouthClosedEyesClosed: relativePath3,
			mouthOpenEyesClosed: relativePath4
		)
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
