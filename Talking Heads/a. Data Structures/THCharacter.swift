//
//  THCharacter.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

// MARK: - Character Description

/// Structured textual description of a character's identity and appearance.
/// Each field is used to build deterministic prompts for AI image generation.
nonisolated struct THCharacterDescription: Codable, Sendable, Hashable {
	var gender: String = ""
	var age: String = ""
	var profession: String = ""
	var lifestyle: String = ""
	var clothingStyle: String = ""
	var personality: String = ""
	var physicalAppearance: String = ""
	var additionalNotes: String = ""

	static let empty = THCharacterDescription ()

	/// Builds a structured text summary for prompt generation.
	var promptSummary: String {
		var parts: [String] = []
		if !gender.isEmpty			{ parts.append ("Gender: \(gender)") }
		if !age.isEmpty				{ parts.append ("Age: \(age)") }
		if !profession.isEmpty		{ parts.append ("Profession: \(profession)") }
		if !lifestyle.isEmpty		{ parts.append ("Lifestyle: \(lifestyle)") }
		if !clothingStyle.isEmpty	{ parts.append ("Clothing: \(clothingStyle)") }
		if !personality.isEmpty		{ parts.append ("Personality: \(personality)") }
		if !physicalAppearance.isEmpty { parts.append ("Appearance: \(physicalAppearance)") }
		if !additionalNotes.isEmpty	{ parts.append ("Notes: \(additionalNotes)") }
		return parts.joined (separator: ". ")
	}
}

// MARK: - Character

/// A persistent character identity used across scenes.
/// One character = one stable identity. No variant derivation.
nonisolated struct THCharacter: Codable, Identifiable, Sendable, Hashable {
	var id: UUID
	var name: String
	var description: THCharacterDescription
	var referenceImagePaths: [String]	// relative to working directory
	var createdAt: Date
	var modifiedAt: Date

	/// Computed prompt base derived from structured description.
	var derivedPromptBase: String {
		var base = "Character: \(name)"
		let desc = description.promptSummary
		if !desc.isEmpty {
			base += ". \(desc)"
		}
		return base
	}

	init (
		id: UUID = UUID (),
		name: String = "Untitled Character",
		description: THCharacterDescription = .empty,
		referenceImagePaths: [String] = [],
		createdAt: Date = Date (),
		modifiedAt: Date = Date ()
	) {
		self.id = id
		self.name = name
		self.description = description
		self.referenceImagePaths = referenceImagePaths
		self.createdAt = createdAt
		self.modifiedAt = modifiedAt
	}
}
