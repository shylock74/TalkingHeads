//
//  THScene.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

// MARK: - Shot Assignment

/// Maps a sentence to a specific shot for rendering.
nonisolated struct THShotAssignment: Codable, Identifiable, Sendable, Hashable {
	var id: UUID
	var sentenceId: UUID
	var shotId: UUID

	init (
		id: UUID = UUID (),
		sentenceId: UUID,
		shotId: UUID
	) {
		self.id = id
		self.sentenceId = sentenceId
		self.shotId = shotId
	}
}

// MARK: - Scene

/// The top-level narrative unit. One scene = one character + one audio file.
/// A scene holds the complete pipeline state from audio import to video render.
///
/// Fundamental constraint: 1 scene = 1 character + 1 environment + 1 audio.
nonisolated struct THScene: Codable, Identifiable, Sendable, Hashable {
	var id: UUID
	var name: String

	/// The character performing in this scene.
	var characterId: UUID

	/// The environment (backdrop) for this scene.
	var environmentId: UUID

	/// Aspect ratio of the sequence/scene.
	var aspectRatio: THAspectRatio

	/// Description of where the character is positioned in the environment.
	var characterPosition: String

	/// Description of the camera positioning setup.
	var cameraSetup: String

	/// Audio analysis results (populated after audio import + VAD).
	var audioSequence: THAudioSequence?
 
	/// Transcription results (populated after ASR).
	var transcript: THTranscript?
 
	/// IDs of shots available in the pool for this scene.
	var shotIds: [UUID]
 
	/// Manual shot assignments (sentence → shot mapping).
	var shotAssignments: [THShotAssignment]
 
	/// Path to the rendered video output, relative to working directory.
	var renderedVideoPath: String?
 
	// Timestamps
	var createdAt: Date
	var modifiedAt: Date
 
	enum CodingKeys: String, CodingKey {
		case id
		case name
		case characterId
		case environmentId
		case aspectRatio
		case characterPosition
		case cameraSetup
		case audioSequence
		case transcript
		case shotIds
		case shotAssignments
		case renderedVideoPath
		case createdAt
		case modifiedAt
	}

	init (from decoder: Decoder) throws {
		let container = try decoder.container (keyedBy: CodingKeys.self)
		id = try container.decode (UUID.self, forKey: .id)
		name = try container.decode (String.self, forKey: .name)
		characterId = try container.decode (UUID.self, forKey: .characterId)
		environmentId = try container.decode (UUID.self, forKey: .environmentId)
		
		// Fallbacks for migration
		aspectRatio = (try? container.decode (THAspectRatio.self, forKey: .aspectRatio)) ?? .ar_16_9
		characterPosition = (try? container.decode (String.self, forKey: .characterPosition)) ?? ""
		cameraSetup = (try? container.decode (String.self, forKey: .cameraSetup)) ?? ""
		
		audioSequence = try container.decodeIfPresent (THAudioSequence.self, forKey: .audioSequence)
		transcript = try container.decodeIfPresent (THTranscript.self, forKey: .transcript)
		shotIds = (try? container.decode ([UUID].self, forKey: .shotIds)) ?? []
		shotAssignments = (try? container.decode ([THShotAssignment].self, forKey: .shotAssignments)) ?? []
		renderedVideoPath = try container.decodeIfPresent (String.self, forKey: .renderedVideoPath)
		createdAt = (try? container.decode (Date.self, forKey: .createdAt)) ?? Date ()
		modifiedAt = (try? container.decode (Date.self, forKey: .modifiedAt)) ?? Date ()
	}

	func encode (to encoder: Encoder) throws {
		var container = encoder.container (keyedBy: CodingKeys.self)
		try container.encode (id, forKey: .id)
		try container.encode (name, forKey: .name)
		try container.encode (characterId, forKey: .characterId)
		try container.encode (environmentId, forKey: .environmentId)
		try container.encode (aspectRatio, forKey: .aspectRatio)
		try container.encode (characterPosition, forKey: .characterPosition)
		try container.encode (cameraSetup, forKey: .cameraSetup)
		try container.encodeIfPresent (audioSequence, forKey: .audioSequence)
		try container.encodeIfPresent (transcript, forKey: .transcript)
		try container.encode (shotIds, forKey: .shotIds)
		try container.encode (shotAssignments, forKey: .shotAssignments)
		try container.encodeIfPresent (renderedVideoPath, forKey: .renderedVideoPath)
		try container.encode (createdAt, forKey: .createdAt)
		try container.encode (modifiedAt, forKey: .modifiedAt)
	}

	init (
		id: UUID = UUID (),
		name: String = "Untitled Scene",
		characterId: UUID,
		environmentId: UUID,
		aspectRatio: THAspectRatio = .ar_16_9,
		characterPosition: String = "",
		cameraSetup: String = "",
		audioSequence: THAudioSequence? = nil,
		transcript: THTranscript? = nil,
		shotIds: [UUID] = [],
		shotAssignments: [THShotAssignment] = [],
		renderedVideoPath: String? = nil,
		createdAt: Date = Date (),
		modifiedAt: Date = Date ()
	) {
		self.id = id
		self.name = name
		self.characterId = characterId
		self.environmentId = environmentId
		self.aspectRatio = aspectRatio
		self.characterPosition = characterPosition
		self.cameraSetup = cameraSetup
		self.audioSequence = audioSequence
		self.transcript = transcript
		self.shotIds = shotIds
		self.shotAssignments = shotAssignments
		self.renderedVideoPath = renderedVideoPath
		self.createdAt = createdAt
		self.modifiedAt = modifiedAt
	}
}
