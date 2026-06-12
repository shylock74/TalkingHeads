//
//  THProjectState.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

// MARK: - Render Settings

/// Global render configuration for video output.
nonisolated struct THRenderSettings: Codable, Sendable, Hashable {
	/// Frames per second for the output video.
	var fps: Double = 30

	/// Output resolution preset.
	var resolution: THResolution = .fullHD

	/// Slow zoom percentage applied per clip (e.g. 12 means 100% → 112%).
	var zoomPercent: Double = 12

	/// Range for random eye blink intervals (seconds).
	var blinkIntervalMin: Double = 1.5
	var blinkIntervalMax: Double = 3.0

	/// Output video codec.
	var outputFormat: THOutputFormat = .h264

	/// Default aspect ratio for new sequences.
	var defaultAspectRatio: THAspectRatio = .ar_16_9

	/// Video bitrate in bits per second (for H.264/H.265).
	var videoBitrate: Int = 5_000_000

	/// Audio bitrate in bits per second.
	var audioBitrate: Int = 192_000

	/// Minimum pause threshold for speech clustering (seconds).
	/// Pauses shorter than this are merged into speech clusters.
	var minPauseThreshold: Double = 0.2

	nonisolated static let `default` = THRenderSettings ()
}

// MARK: - Project State

/// The root-level data model for a TalkingHeads project.
/// Serialized as `project.json` inside the `.thproject` package.
/// Contains ONLY references to assets — no binary data.
nonisolated struct THProjectState: Codable, Sendable {
	/// Schema version for migration support.
	var version: Int = 1

	/// All characters in the project.
	var characters: [THCharacter]

	/// All environments in the project.
	var environments: [THEnvironment]

	/// All generated shots (each with 4 image variants).
	var shots: [THShot]

	/// All scenes (each = 1 character + 1 environment + 1 audio).
	var scenes: [THScene]

	/// Global render configuration.
	var renderSettings: THRenderSettings

	/// Project timestamps.
	var createdAt: Date
	var modifiedAt: Date

	init (
		version: Int = 1,
		characters: [THCharacter] = [],
		environments: [THEnvironment] = [],
		shots: [THShot] = [],
		scenes: [THScene] = [],
		renderSettings: THRenderSettings = .default,
		createdAt: Date = Date (),
		modifiedAt: Date = Date ()
	) {
		self.version = version
		self.characters = characters
		self.environments = environments
		self.shots = shots
		self.scenes = scenes
		self.renderSettings = renderSettings
		self.createdAt = createdAt
		self.modifiedAt = modifiedAt
	}

	/// Creates a fresh, empty project state.
	nonisolated static var empty: THProjectState {
		THProjectState ()
	}
}
