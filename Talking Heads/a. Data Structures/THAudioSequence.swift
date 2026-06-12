//
//  THAudioSequence.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

// MARK: - Audio Segment

/// A single contiguous time span classified as either speech or silence.
/// These are the raw output of Voice Activity Detection (VAD).
nonisolated struct THAudioSegment: Codable, Identifiable, Sendable, Hashable {
	var id: UUID
	var startTime: Double
	var endTime: Double
	var isSpeech: Bool

	var duration: Double { endTime - startTime }

	init (
		id: UUID = UUID (),
		startTime: Double,
		endTime: Double,
		isSpeech: Bool
	) {
		self.id = id
		self.startTime = startTime
		self.endTime = endTime
		self.isSpeech = isSpeech
	}
}

// MARK: - Speech Cluster

/// A cluster of speech segments, formed by merging speech segments
/// that are separated by pauses shorter than the minimum pause threshold (0.2s).
/// Each cluster represents a continuous "block" of speaking.
nonisolated struct THSpeechCluster: Codable, Identifiable, Sendable, Hashable {
	var id: UUID
	var startTime: Double
	var endTime: Double

	/// The individual micro-segments within this cluster.
	/// Includes both speech and very short silences (< threshold).
	var segments: [THAudioSegment]

	var duration: Double { endTime - startTime }

	init (
		id: UUID = UUID (),
		startTime: Double,
		endTime: Double,
		segments: [THAudioSegment] = []
	) {
		self.id = id
		self.startTime = startTime
		self.endTime = endTime
		self.segments = segments
	}
}

// MARK: - Audio Sequence

/// The complete audio analysis result for a single audio file.
/// Contains raw VAD segments and computed speech clusters.
nonisolated struct THAudioSequence: Codable, Sendable, Hashable {
	/// Relative path to the audio file within the project working directory.
	var audioFilePath: String

	/// Total duration of the audio in seconds.
	var duration: Double

	/// Raw VAD segments (speech/silence classification).
	var segments: [THAudioSegment]

	/// Computed speech clusters (merged speech blocks).
	var clusters: [THSpeechCluster]

	/// Minimum pause threshold used for clustering (seconds).
	var minPauseThreshold: Double = 0.2

	init (
		audioFilePath: String = "",
		duration: Double = 0,
		segments: [THAudioSegment] = [],
		clusters: [THSpeechCluster] = [],
		minPauseThreshold: Double = 0.2
	) {
		self.audioFilePath = audioFilePath
		self.duration = duration
		self.segments = segments
		self.clusters = clusters
		self.minPauseThreshold = minPauseThreshold
	}
}
