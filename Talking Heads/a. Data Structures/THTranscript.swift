//
//  THTranscript.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

// MARK: - Sentence

/// A single sentence extracted from the transcription.
/// Sentences are the atomic unit for shot assignment:
/// each sentence gets exactly one shot (camera angle).
nonisolated struct THSentence: Codable, Identifiable, Sendable, Hashable {
	var id: UUID
	var text: String
	var startTime: Double
	var endTime: Double

	/// The punctuation that terminates this sentence.
	var punctuation: THPunctuation

	/// The shot assigned to this sentence for rendering.
	/// nil if not yet assigned.
	var assignedShotId: UUID?

	var duration: Double { endTime - startTime }

	init (
		id: UUID = UUID (),
		text: String = "",
		startTime: Double = 0,
		endTime: Double = 0,
		punctuation: THPunctuation = .none,
		assignedShotId: UUID? = nil
	) {
		self.id = id
		self.text = text
		self.startTime = startTime
		self.endTime = endTime
		self.punctuation = punctuation
		self.assignedShotId = assignedShotId
	}
}

// MARK: - Transcript

/// Full transcription of an audio file, segmented into sentences.
/// Sentence boundaries are determined by punctuation:
/// `.` `!` `?` `:` `;` `...` create shot change points.
/// Commas do NOT create shot changes.
nonisolated struct THTranscript: Codable, Sendable, Hashable {
	/// The complete transcription text.
	var fullText: String

	/// Sentences split at punctuation boundaries.
	var sentences: [THSentence]

	/// Total number of sentences that represent shot-change boundaries
	/// (i.e. sentences ending with `.`, `!`, `?`, `:`, `;`, `...`).
	var shotChangeCount: Int {
		sentences.filter { $0.punctuation.isSentenceBreak }.count
	}

	init (
		fullText: String = "",
		sentences: [THSentence] = []
	) {
		self.fullText = fullText
		self.sentences = sentences
	}
}
