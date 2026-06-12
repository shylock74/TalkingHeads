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
