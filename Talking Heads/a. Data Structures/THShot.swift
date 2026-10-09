//
//  THShot.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

// MARK: - Shot Variants

/// The four image variants generated for each shot.
/// Each variant represents a different mouth/eye state for animation.
nonisolated struct THShotVariants: Codable, Sendable, Hashable {
	/// Neutral resting pose — mouth closed, eyes open.
	var mouthClosedEyesOpen: String?

	/// Speaking pose — mouth open, eyes open.
	var mouthOpenEyesOpen: String?

	/// Neutral with blink — mouth closed, eyes closed.
	var mouthClosedEyesClosed: String?

	/// Speaking with blink — mouth open, eyes closed.
	var mouthOpenEyesClosed: String?

	static let empty = THShotVariants ()

	/// Returns the image path for a given frame variant, or nil if not generated.
	func imagePath (for variant: THFrameVariant) -> String? {
		switch variant {
		case .mouthClosedEyesOpen:	return mouthClosedEyesOpen
		case .mouthOpenEyesOpen:	return mouthOpenEyesOpen
		case .mouthClosedEyesClosed:	return mouthClosedEyesClosed
		case .mouthOpenEyesClosed:	return mouthOpenEyesClosed
		}
	}

	/// Whether all four variants have been generated.
	var isComplete: Bool {
		mouthClosedEyesOpen != nil &&
		mouthOpenEyesOpen != nil &&
		mouthClosedEyesClosed != nil &&
		mouthOpenEyesClosed != nil
	}

	/// Number of generated variants (0–4).
	var generatedCount: Int {
		[mouthClosedEyesOpen, mouthOpenEyesOpen,
		 mouthClosedEyesClosed, mouthOpenEyesClosed]
			.compactMap { $0 }
			.count
	}
}

// MARK: - Shot

/// A visual shot definition: one specific camera framing of a character in an environment.
/// The user generates shots, reviews them, and approves/rejects them.
/// Approved shots become part of the available pool for scene rendering.
nonisolated struct THShot: Codable, Identifiable, Sendable, Hashable {
	var id: UUID
	var characterId: UUID
	var environmentId: UUID

	// Camera setup
	var shotType: THShotType
	var cameraAngle: String
	var lensStyle: String
	var compositionNotes: String
	var cameraSetup: String
	var characterPosition: String

	// Generation metadata
	var promptUsed: String
	var seedValue: Int?

	// Image variants (4 states)
	var variants: THShotVariants

	// User approval
	var isApproved: Bool

	// Timestamps
	var createdAt: Date
	var modifiedAt: Date

	enum CodingKeys: String, CodingKey {
		case id
		case characterId
		case environmentId
		case shotType
		case cameraAngle
		case lensStyle
		case compositionNotes
		case cameraSetup
		case characterPosition
		case promptUsed
		case seedValue
		case variants
		case isApproved
		case createdAt
		case modifiedAt
	}

	init (
		id: UUID = UUID (),
		characterId: UUID,
		environmentId: UUID,
		shotType: THShotType = .mediumShot,
		cameraAngle: String = "Front",
		lensStyle: String = "Standard 50mm",
		compositionNotes: String = "",
		cameraSetup: String = "",
		characterPosition: String = "",
		promptUsed: String = "",
		seedValue: Int? = nil,
		variants: THShotVariants = .empty,
		isApproved: Bool = false,
		createdAt: Date = Date (),
		modifiedAt: Date = Date ()
	) {
		self.id = id
		self.characterId = characterId
		self.environmentId = environmentId
		self.shotType = shotType
		self.cameraAngle = cameraAngle
		self.lensStyle = lensStyle
		self.compositionNotes = compositionNotes
		self.cameraSetup = cameraSetup
		self.characterPosition = characterPosition
		self.promptUsed = promptUsed
		self.seedValue = seedValue
		self.variants = variants
		self.isApproved = isApproved
		self.createdAt = createdAt
		self.modifiedAt = modifiedAt
	}

	init (from decoder: Decoder) throws {
		let container = try decoder.container (keyedBy: CodingKeys.self)
		id = try container.decode (UUID.self, forKey: .id)
		characterId = try container.decode (UUID.self, forKey: .characterId)
		environmentId = try container.decode (UUID.self, forKey: .environmentId)
		shotType = try container.decode (THShotType.self, forKey: .shotType)
		cameraAngle = try container.decode (String.self, forKey: .cameraAngle)
		lensStyle = try container.decode (String.self, forKey: .lensStyle)
		compositionNotes = try container.decode (String.self, forKey: .compositionNotes)
		cameraSetup = (try? container.decode (String.self, forKey: .cameraSetup)) ?? ""
		characterPosition = (try? container.decode (String.self, forKey: .characterPosition)) ?? ""
		promptUsed = try container.decode (String.self, forKey: .promptUsed)
		seedValue = try container.decodeIfPresent (Int.self, forKey: .seedValue)
		variants = try container.decode (THShotVariants.self, forKey: .variants)
		isApproved = try container.decode (Bool.self, forKey: .isApproved)
		createdAt = try container.decode (Date.self, forKey: .createdAt)
		modifiedAt = try container.decode (Date.self, forKey: .modifiedAt)
	}

	func encode (to encoder: Encoder) throws {
		var container = encoder.container (keyedBy: CodingKeys.self)
		try container.encode (id, forKey: .id)
		try container.encode (characterId, forKey: .characterId)
		try container.encode (environmentId, forKey: .environmentId)
		try container.encode (shotType, forKey: .shotType)
		try container.encode (cameraAngle, forKey: .cameraAngle)
		try container.encode (lensStyle, forKey: .lensStyle)
		try container.encode (compositionNotes, forKey: .compositionNotes)
		try container.encode (cameraSetup, forKey: .cameraSetup)
		try container.encode (characterPosition, forKey: .characterPosition)
		try container.encode (promptUsed, forKey: .promptUsed)
		try container.encodeIfPresent (seedValue, forKey: .seedValue)
		try container.encode (variants, forKey: .variants)
		try container.encode (isApproved, forKey: .isApproved)
		try container.encode (createdAt, forKey: .createdAt)
		try container.encode (modifiedAt, forKey: .modifiedAt)
	}
}
