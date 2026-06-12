//
//  THDefaultData.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

// MARK: - Default Data

/// Default values, sample data, and constants for the TalkingHeads application.
enum THDefaultData {

	// MARK: - Render Defaults

	/// Default render settings.
	static let defaultRenderSettings = THRenderSettings ()

	// MARK: - Shot Type Descriptions

	/// Descriptions for each shot type, useful for prompt generation.
	static let shotTypeDescriptions: [THShotType: String] = [
		.wideShot:			"Full body visible, character seen from a distance within the environment. Establishes location and context.",
		.mediumShot:		"Character visible from the waist up. Balances the character and environment, standard conversational framing.",
		.mediumCloseUp:		"Character visible from the chest up. Shows facial expressions while retaining some environment context.",
		.closeUp:			"Character's face fills most of the frame. Emphasizes emotions and reactions, limited environment visible.",
		.extremeCloseUp:	"Tight framing on specific facial features (eyes, mouth). Maximum emotional impact, no environment visible."
	]

	// MARK: - Camera Angles

	/// Common camera angles for shot generation.
	static let cameraAngles = [
		"Front",
		"Three-Quarter Left",
		"Three-Quarter Right",
		"Profile Left",
		"Profile Right",
		"Slight Low Angle",
		"Slight High Angle",
		"Over the Shoulder"
	]

	// MARK: - Lens Styles

	/// Common lens style descriptions for prompt generation.
	static let lensStyles = [
		"Standard 50mm",
		"Wide 35mm",
		"Telephoto 85mm",
		"Portrait 105mm",
		"Cinematic 24mm",
		"Macro Close-Up"
	]

	// MARK: - Environment Subcategories

	/// Suggested subcategories for indoor environments.
	static let indoorSubcategories = [
		"Office", "Studio", "Living Room", "Bedroom", "Kitchen",
		"Library", "Laboratory", "Classroom", "Lobby", "Warehouse",
		"Restaurant", "Bar", "Hospital", "Gallery", "Theater"
	]

	/// Suggested subcategories for outdoor environments.
	static let outdoorSubcategories = [
		"Street", "Park", "Beach", "Forest", "Mountain",
		"Rooftop", "Garden", "Courtyard", "Parking Lot", "Bridge",
		"Highway", "Train Station", "Airport", "Harbor", "Playground"
	]

	// MARK: - Sample Character

	/// A sample character for testing.
	static var sampleCharacter: THCharacter {
		THCharacter (
			name: "Dr. Elena Vasquez",
			description: THCharacterDescription (
				gender: "Female",
				age: "42",
				profession: "Quantum Physics Researcher",
				lifestyle: "Academic, methodical, coffee enthusiast",
				clothingStyle: "Smart casual — blazer over a simple blouse",
				personality: "Analytical, calm under pressure, dry humor",
				physicalAppearance: "Mediterranean features, dark wavy hair to shoulders, wire-rimmed glasses, warm brown eyes",
				additionalNotes: "Often gestures when explaining complex concepts"
			)
		)
	}

	// MARK: - Sample Environment

	/// A sample environment for testing.
	static var sampleEnvironment: THEnvironment {
		THEnvironment (
			name: "University Office",
			description: "A cozy academic office filled with books and research papers",
			category: .indoor,
			subcategory: "Office",
			visualStyle: THVisualStyle (
				architecturalStyle: "Modern academic",
				visualStyle: "Warm and cluttered",
				dominantPalette: "Warm browns, cream, dark wood",
				materials: "Wood, leather, paper",
				detailLevel: "High — books, papers, diagrams on walls"
			),
			lighting: THLightingConfig (
				timeOfDay: "Late afternoon",
				season: "Autumn",
				weather: "Overcast",
				lightingType: "Warm desk lamp + window light",
				colorTemperature: "3200K warm"
			),
			atmosphere: THAtmosphereConfig (
				mood: "Contemplative, intellectual",
				activityLevel: "Quiet, focused"
			)
		)
	}
}
