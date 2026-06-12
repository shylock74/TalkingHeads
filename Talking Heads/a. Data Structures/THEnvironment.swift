//
//  THEnvironment.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

// MARK: - Environment

/// A structured environment definition representing a location/setting.
/// Environments provide the visual backdrop for character shots.
nonisolated struct THEnvironment: Codable, Identifiable, Sendable, Hashable {
	var id: UUID
	var name: String
	var description: String

	// Classification
	var category: THEnvironmentCategory
	var subcategory: String				// "office", "studio", "street", etc.

	// Visual properties
	var visualStyle: THVisualStyle
	var lighting: THLightingConfig
	var atmosphere: THAtmosphereConfig

	// References
	var referenceImagePaths: [String]	// relative to working directory
	var notes: String

	// Timestamps
	var createdAt: Date
	var modifiedAt: Date

	/// Builds a structured text summary for prompt generation.
	var promptSummary: String {
		var parts: [String] = []
		parts.append ("Environment: \(name)")
		if !description.isEmpty			{ parts.append (description) }
		parts.append ("Type: \(category.displayName) — \(subcategory)")

		// Visual style
		if !visualStyle.architecturalStyle.isEmpty	{ parts.append ("Architecture: \(visualStyle.architecturalStyle)") }
		if !visualStyle.visualStyle.isEmpty			{ parts.append ("Style: \(visualStyle.visualStyle)") }
		if !visualStyle.dominantPalette.isEmpty		{ parts.append ("Palette: \(visualStyle.dominantPalette)") }
		if !visualStyle.materials.isEmpty			{ parts.append ("Materials: \(visualStyle.materials)") }

		// Lighting
		if !lighting.timeOfDay.isEmpty		{ parts.append ("Time: \(lighting.timeOfDay)") }
		if !lighting.weather.isEmpty		{ parts.append ("Weather: \(lighting.weather)") }
		if !lighting.lightingType.isEmpty	{ parts.append ("Lighting: \(lighting.lightingType)") }

		// Atmosphere
		if !atmosphere.mood.isEmpty			{ parts.append ("Mood: \(atmosphere.mood)") }

		return parts.joined (separator: ". ")
	}

	init (
		id: UUID = UUID (),
		name: String = "Untitled Environment",
		description: String = "",
		category: THEnvironmentCategory = .indoor,
		subcategory: String = "",
		visualStyle: THVisualStyle = .empty,
		lighting: THLightingConfig = .empty,
		atmosphere: THAtmosphereConfig = .empty,
		referenceImagePaths: [String] = [],
		notes: String = "",
		createdAt: Date = Date (),
		modifiedAt: Date = Date ()
	) {
		self.id = id
		self.name = name
		self.description = description
		self.category = category
		self.subcategory = subcategory
		self.visualStyle = visualStyle
		self.lighting = lighting
		self.atmosphere = atmosphere
		self.referenceImagePaths = referenceImagePaths
		self.notes = notes
		self.createdAt = createdAt
		self.modifiedAt = modifiedAt
	}
}
