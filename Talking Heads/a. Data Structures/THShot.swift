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

	init (
		id: UUID = UUID (),
		characterId: UUID,
		environmentId: UUID,
		shotType: THShotType = .mediumShot,
		cameraAngle: String = "Front",
		lensStyle: String = "Standard 50mm",
		compositionNotes: String = "",
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
		self.promptUsed = promptUsed
		self.seedValue = seedValue
		self.variants = variants
		self.isApproved = isApproved
		self.createdAt = createdAt
		self.modifiedAt = modifiedAt
	}
}
