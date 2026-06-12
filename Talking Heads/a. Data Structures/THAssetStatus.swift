//
//  THAssetStatus.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

// MARK: - Asset Status

/// Status of a single asset file on disk.
nonisolated enum THAssetStatus: String, Codable, Sendable {
	/// File exists and is valid.
	case available

	/// File is missing from disk.
	case missing

	/// File exists but cache is invalidated (needs regeneration).
	case outdated
}

// MARK: - Asset Check Result

/// Result of checking a single asset's integrity.
nonisolated struct THAssetCheckResult: Identifiable, Sendable {
	var id: UUID = UUID ()

	/// The relative path that was checked.
	var relativePath: String

	/// The status found.
	var status: THAssetStatus

	/// Descriptive context about where this asset is used.
	var context: String
}

// MARK: - Asset Report

/// Summary report of asset integrity for the entire project.
/// Generated on project open and available for UI display.
nonisolated struct THAssetReport: Sendable {
	/// Assets that are missing from disk.
	var missingAssets: [THAssetCheckResult]

	/// Assets that exist but are outdated (cache invalidated).
	var outdatedAssets: [THAssetCheckResult]

	/// Total number of available (healthy) assets.
	var availableCount: Int

	/// Total number of assets checked.
	var totalCount: Int {
		availableCount + missingAssets.count + outdatedAssets.count
	}

	/// Whether the project is fully healthy (no missing or outdated assets).
	var isHealthy: Bool {
		missingAssets.isEmpty && outdatedAssets.isEmpty
	}

	/// A human-readable summary string for the UI.
	var summary: String {
		if isHealthy {
			return "All \(availableCount) assets available"
		}
		var parts: [String] = []
		if !missingAssets.isEmpty {
			parts.append ("\(missingAssets.count) missing")
		}
		if !outdatedAssets.isEmpty {
			parts.append ("\(outdatedAssets.count) outdated")
		}
		return parts.joined (separator: ", ")
	}

	static let empty = THAssetReport (
		missingAssets: [],
		outdatedAssets: [],
		availableCount: 0
	)
}
