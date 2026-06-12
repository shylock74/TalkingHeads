//
//  THEnums.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

// MARK: - Environment

/// Classifies an environment as indoor or outdoor.
nonisolated enum THEnvironmentCategory: String, Codable, Sendable, CaseIterable, Identifiable {
	case indoor
	case outdoor

	var id: String { rawValue }

	var displayName: String {
		switch self {
		case .indoor:	return "Indoor"
		case .outdoor:	return "Outdoor"
		}
	}
}

// MARK: - Visual Style

/// Architectural / visual style descriptors for environments.
nonisolated struct THVisualStyle: Codable, Sendable, Hashable {
	var architecturalStyle: String = ""
	var visualStyle: String = ""
	var dominantPalette: String = ""
	var materials: String = ""
	var detailLevel: String = ""

	static let empty = THVisualStyle ()
}

// MARK: - Lighting

/// Lighting configuration for environments.
nonisolated struct THLightingConfig: Codable, Sendable, Hashable {
	var timeOfDay: String = ""
	var season: String = ""
	var weather: String = ""
	var lightingType: String = ""
	var colorTemperature: String = ""

	static let empty = THLightingConfig ()
}

// MARK: - Atmosphere

/// Atmosphere / mood configuration for environments.
nonisolated struct THAtmosphereConfig: Codable, Sendable, Hashable {
	var mood: String = ""
	var activityLevel: String = ""

	static let empty = THAtmosphereConfig ()
}

// MARK: - Shot Types

/// Camera framing categories.
nonisolated enum THShotType: String, Codable, Sendable, CaseIterable, Identifiable {
	case wideShot
	case mediumShot
	case mediumCloseUp
	case closeUp
	case extremeCloseUp

	var id: String { rawValue }

	var displayName: String {
		switch self {
		case .wideShot:			return "Wide Shot"
		case .mediumShot:		return "Medium Shot"
		case .mediumCloseUp:	return "Medium Close-Up"
		case .closeUp:			return "Close-Up"
		case .extremeCloseUp:	return "Extreme Close-Up"
		}
	}

	/// Short abbreviation for compact UI.
	var abbreviation: String {
		switch self {
		case .wideShot:			return "WS"
		case .mediumShot:		return "MS"
		case .mediumCloseUp:	return "MCU"
		case .closeUp:			return "CU"
		case .extremeCloseUp:	return "ECU"
		}
	}
}

// MARK: - Output Format

/// Video export codec selection.
nonisolated enum THOutputFormat: String, Codable, Sendable, CaseIterable, Identifiable {
	case h264
	case h265
	case prores422
	case prores4444

	var id: String { rawValue }

	var displayName: String {
		switch self {
		case .h264:			return "H.264"
		case .h265:			return "H.265 (HEVC)"
		case .prores422:	return "ProRes 422"
		case .prores4444:	return "ProRes 4444"
		}
	}
}

// MARK: - Resolution Presets

/// Common resolution presets.
nonisolated enum THResolution: String, Codable, Sendable, CaseIterable, Identifiable {
	case hd720		// 1280x720
	case fullHD		// 1920x1080
	case qhd		// 2560x1440
	case uhd4k		// 3840x2160

	var id: String { rawValue }

	var size: CGSize {
		switch self {
		case .hd720:	return CGSize (width: 1280, height: 720)
		case .fullHD:	return CGSize (width: 1920, height: 1080)
		case .qhd:		return CGSize (width: 2560, height: 1440)
		case .uhd4k:	return CGSize (width: 3840, height: 2160)
		}
	}

	var displayName: String {
		switch self {
		case .hd720:	return "720p HD"
		case .fullHD:	return "1080p Full HD"
		case .qhd:		return "1440p QHD"
		case .uhd4k:	return "4K UHD"
		}
	}
}

// MARK: - Aspect Ratio

/// Supported aspect ratios for sequences.
nonisolated enum THAspectRatio: String, Codable, Sendable, CaseIterable, Identifiable {
	case ar_1_1 = "1:1"
	case ar_9_16 = "9:16"
	case ar_16_9 = "16:9"
	case ar_3_4 = "3:4"
	case ar_4_3 = "4:3"
	case ar_2_3 = "2:3"
	case ar_3_2 = "3:2"
	case ar_21_9 = "21:9"

	var id: String { rawValue }

	var displayName: String { rawValue }
}


// MARK: - Punctuation

/// Punctuation types that determine sentence boundaries.
nonisolated enum THPunctuation: String, Codable, Sendable, CaseIterable {
	case period			= "."
	case exclamation	= "!"
	case question		= "?"
	case colon			= ":"
	case semicolon		= ";"
	case ellipsis		= "..."
	case comma			= ","
	case none			= ""

	/// Whether this punctuation marks a true sentence break (shot change point).
	/// Commas are NOT sentence breaks.
	var isSentenceBreak: Bool {
		switch self {
		case .period, .exclamation, .question:
			return true
		case .colon, .semicolon, .ellipsis:
			return true
		case .comma, .none:
			return false
		}
	}
}

// MARK: - Frame Variants (Animation)

/// The four possible visual states of a character frame.
/// Combinations of mouth (open/closed) × eyes (open/closed).
nonisolated enum THFrameVariant: String, Codable, Sendable, CaseIterable {
	case mouthClosedEyesOpen
	case mouthOpenEyesOpen
	case mouthClosedEyesClosed
	case mouthOpenEyesClosed
}

// MARK: - Sidebar Navigation

/// Sidebar navigation sections.
nonisolated enum THSidebarSection: String, CaseIterable, Identifiable {
	case characters
	case environments
	case scenes

	var id: String { rawValue }

	var displayName: String {
		switch self {
		case .characters:	return "Characters"
		case .environments:	return "Environments"
		case .scenes:		return "Scenes"
		}
	}

	var iconName: String {
		switch self {
		case .characters:	return "person.2.fill"
		case .environments:	return "photo.on.rectangle.angled"
		case .scenes:		return "film.stack"
		}
	}
}
