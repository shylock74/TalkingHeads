//
//  THFileUtils.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import Foundation

// MARK: - File Utilities

/// Path and file utilities for the TalkingHeads project filesystem.
enum THFileUtils {

	/// The standard subdirectory names inside a `.thproject` package.
	static let subdirectories = [
		"audio",
		"characters",
		"environments",
		"shots",
		"clips",
		"renders",
		"transcripts"
	]

	/// Ensures all required subdirectories exist within a project directory.
	/// - Parameter projectURL: The root URL of the `.thproject` package.
	static func ensureDirectoryStructure (at projectURL: URL) throws {
		let fm = FileManager.default
		for dirName in subdirectories {
			let dirURL = projectURL.appendingPathComponent (dirName)
			if !fm.fileExists (atPath: dirURL.path) {
				try fm.createDirectory (at: dirURL, withIntermediateDirectories: true)
			}
		}
	}

	/// Copies a file into the project directory under the specified subdirectory.
	/// - Parameters:
	///   - sourceURL: The source file URL.
	///   - subdirectory: The subdirectory name (e.g. "audio", "characters").
	///   - projectURL: The root URL of the `.thproject` package.
	/// - Returns: The relative path from the project root to the copied file.
	@discardableResult
	static func copyIntoProject (
		source sourceURL: URL,
		subdirectory: String,
		projectURL: URL
	) throws -> String {
		let fm = FileManager.default
		let destDir = projectURL.appendingPathComponent (subdirectory)
		if !fm.fileExists (atPath: destDir.path) {
			try fm.createDirectory (at: destDir, withIntermediateDirectories: true)
		}

		let destURL = destDir.appendingPathComponent (sourceURL.lastPathComponent)

		// Remove existing file if present
		if fm.fileExists (atPath: destURL.path) {
			try fm.removeItem (at: destURL)
		}
		try fm.copyItem (at: sourceURL, to: destURL)

		return "\(subdirectory)/\(sourceURL.lastPathComponent)"
	}

	/// Resolves a relative asset path to an absolute URL within the project.
	/// - Parameters:
	///   - relativePath: The relative path stored in the project JSON.
	///   - projectURL: The root URL of the `.thproject` package.
	/// - Returns: The absolute file URL.
	static func resolveAssetPath (_ relativePath: String, projectURL: URL) -> URL {
		projectURL.appendingPathComponent (relativePath)
	}

	/// Checks whether a file exists at a relative path within the project.
	/// - Parameters:
	///   - relativePath: The relative path stored in the project JSON.
	///   - projectURL: The root URL of the `.thproject` package.
	/// - Returns: `true` if the file exists on disk.
	static func assetExists (_ relativePath: String, projectURL: URL) -> Bool {
		let absoluteURL = resolveAssetPath (relativePath, projectURL: projectURL)
		return FileManager.default.fileExists (atPath: absoluteURL.path)
	}

	/// Generates a unique filename by appending a UUID suffix.
	/// - Parameters:
	///   - baseName: The original filename (e.g. "photo.png").
	/// - Returns: A unique filename (e.g. "photo_A1B2C3D4.png").
	static func uniqueFilename (from baseName: String) -> String {
		let url = URL (fileURLWithPath: baseName)
		let name = url.deletingPathExtension ().lastPathComponent
		let ext = url.pathExtension
		let suffix = UUID ().uuidString.prefix (8)
		if ext.isEmpty {
			return "\(name)_\(suffix)"
		}
		return "\(name)_\(suffix).\(ext)"
	}
}
