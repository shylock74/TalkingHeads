//
//  THPromptEngine.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

/// Builds prompts for generating character image variants.
enum THPromptEngine {
	
	/// Builds a detailed text prompt for a specific frame variant.
	/// - Parameters:
	///   - character: The character description.
	///   - environment: The environment description.
	///   - shotType: The framing type (e.g. mediumShot, closeUp).
	///   - variant: The mouth/eye variant we want to generate.
	/// - Returns: A complete string prompt suitable for Gemini Imagen.
	static func buildPrompt (
		for character: THCharacter,
		in environment: THEnvironment,
		shotType: THShotType,
		variant: THFrameVariant,
		characterPosition: String = "",
		cameraSetup: String = ""
	) -> String {
		let charPrompt = character.derivedPromptBase
		let envPrompt = environment.promptSummary
		
		// Map the framing type
		let framingText: String
		switch shotType {
		case .wideShot:
			framingText = "Wide shot showing the full body from a distance."
		case .mediumShot:
			framingText = "Medium shot, from the waist up."
		case .mediumCloseUp:
			framingText = "Medium close-up shot, from the chest up."
		case .closeUp:
			framingText = "Close-up portrait shot, emphasizing facial expressions."
		case .extremeCloseUp:
			framingText = "Extreme close-up shot focusing tightly on the face."
		}
		
		// Map the micro-expression instructions for animation compatibility
		let expressionText: String
		let identityInstruction: String
		switch variant {
		case .mouthClosedEyesOpen:
			expressionText = "Neutral resting facial expression, mouth closed, lips naturally pressed together, eyes wide open looking directly at the camera."
			identityInstruction = ""
		case .mouthOpenEyesOpen:
			expressionText = "Speaking facial expression, mouth slightly open, lips parted, teeth showing slightly as if talking, eyes wide open looking directly at the camera."
			identityInstruction = "CRITICAL: The generated image must be absolutely identical to the provided reference image in terms of background, character identity, pose, clothing, hair, lighting, and composition. The only difference is that the mouth must be open/parted as if speaking. Everything else must remain unchanged."
		case .mouthClosedEyesClosed:
			expressionText = "Blinking facial expression, eyes completely closed, eyelids relaxed, mouth closed, lips naturally pressed together."
			identityInstruction = "CRITICAL: The generated image must be absolutely identical to the provided reference image in terms of background, character identity, pose, clothing, hair, lighting, and composition. The only difference is that the eyes must be completely closed (blinking). Everything else must remain unchanged."
		case .mouthOpenEyesClosed:
			expressionText = "Speaking and blinking facial expression, mouth slightly open, lips parted, eyes completely closed, eyelids relaxed."
			identityInstruction = "CRITICAL: The generated image must be absolutely identical to the provided reference image in terms of background, character identity, pose, clothing, hair, lighting, and composition. The only difference is that the eyes must be completely closed (blinking) and the mouth must be open/parted as if speaking. Everything else must remain unchanged."
		}
		
		var placementText = ""
		if !characterPosition.isEmpty {
			placementText += "The character position in the scene is: \(characterPosition). "
		}
		if !cameraSetup.isEmpty {
			placementText += "The camera setup is: \(cameraSetup). "
		}
		
		var referenceInstructions = ""
		if !character.referenceImagePaths.isEmpty {
			referenceInstructions += "The attached images contain character reference sheets/portraits. The generated character must match the face, facial features, hair style, clothing, and overall visual appearance of the character in these reference images exactly. "
		}
		if !environment.referenceImagePaths.isEmpty {
			referenceInstructions += "The attached images contain environment reference backdrops. The background setting, architecture, colors, and layout must match these environment reference images. "
		}
		
		return """
		A professional high-resolution photograph. \
		\(identityInstruction.isEmpty ? "" : "\(identityInstruction) ")\
		\(framingText) \(expressionText) \
		\(charPrompt). \
		\(placementText)\
		\(referenceInstructions)\
		Background setting: \(envPrompt). \
		Photorealistic style, consistent lighting, clean composition, studio camera quality.
		"""
	}
}
