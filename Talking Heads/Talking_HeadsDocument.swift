//
//  Talking_HeadsDocument.swift
//  Talking Heads
//
//  Created by Alex Raccuglia on 12/06/2026.
//

import SwiftUI
import UniformTypeIdentifiers

// MARK: - UTType Extension

extension UTType {
	/// Custom UTI for TalkingHeads project packages.
	nonisolated static let thProject = UTType (exportedAs: "media.ulti.thproject")
}

// MARK: - Document

/// A document-based model for TalkingHeads projects.
///
/// The document is stored as a **directory package** (`.thproject`) containing:
/// - `project.json` — serialized `THProjectState`
/// - `/audio/` — imported audio files
/// - `/characters/` — character reference images
/// - `/environments/` — environment reference images
/// - `/shots/` — generated shot images (4 variants per shot)
/// - `/clips/` — rendered clip segments
/// - `/renders/` — final rendered videos
/// - `/transcripts/` — transcription data
///
/// The document itself holds only JSON references — all binary assets
/// live as files within the package directory.
nonisolated struct Talking_HeadsDocument: FileDocument {

	// MARK: - Properties

	/// The project state (serialized to/from `project.json`).
	var projectState: THProjectState

	// MARK: - Content Types

	static let readableContentTypes: [UTType] = [.thProject]

	/// Names of subdirectories that are created inside each project package.
	static let assetDirectories = [
		"audio",
		"characters",
		"environments",
		"shots",
		"clips",
		"renders",
		"transcripts"
	]

	// MARK: - Init

	/// Creates a new empty document with default project state.
	init (projectState: THProjectState = .empty) {
		self.projectState = projectState
	}

	// MARK: - Read

	/// Reads a `.thproject` package from disk.
	/// Expects a directory `FileWrapper` containing `project.json`.
	init (configuration: ReadConfiguration) throws {
		guard let directoryWrapper = configuration.file.fileWrappers,
			  let projectFileWrapper = directoryWrapper ["project.json"],
			  let data = projectFileWrapper.regularFileContents
		else {
			throw CocoaError (.fileReadCorruptFile)
		}

		let decoder = JSONDecoder ()
		decoder.dateDecodingStrategy = .iso8601
		self.projectState = try decoder.decode (THProjectState.self, from: data)
	}

	// MARK: - Write

	/// Writes the `.thproject` package to disk.
	/// Produces a directory `FileWrapper` with `project.json` and asset subdirectories.
	func fileWrapper (configuration: WriteConfiguration) throws -> FileWrapper {
		// Encode project state to JSON
		let encoder = JSONEncoder ()
		encoder.dateEncodingStrategy = .iso8601
		encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
		let jsonData = try encoder.encode (projectState)

		// Create the project.json file wrapper
		let projectFileWrapper = FileWrapper (regularFileWithContents: jsonData)
		projectFileWrapper.preferredFilename = "project.json"

		// If updating an existing document, preserve existing file wrappers
		if let existingWrappers = configuration.existingFile?.fileWrappers {
			// Start from existing directory structure
			let directoryWrapper = FileWrapper (directoryWithFileWrappers: existingWrappers)

			// Replace the project.json with updated version
			if let oldProjectFile = directoryWrapper.fileWrappers? ["project.json"] {
				directoryWrapper.removeFileWrapper (oldProjectFile)
			}
			directoryWrapper.addFileWrapper (projectFileWrapper)

			// Ensure all asset directories exist
			for dirName in Self.assetDirectories {
				if directoryWrapper.fileWrappers? [dirName] == nil {
					let subDir = FileWrapper (directoryWithFileWrappers: [:])
					subDir.preferredFilename = dirName
					directoryWrapper.addFileWrapper (subDir)
				}
			}

			return directoryWrapper
		}

		// Creating a new document — build directory structure from scratch
		var childWrappers: [String : FileWrapper] = [:]
		childWrappers ["project.json"] = projectFileWrapper

		// Create empty asset subdirectories
		for dirName in Self.assetDirectories {
			let subDir = FileWrapper (directoryWithFileWrappers: [:])
			subDir.preferredFilename = dirName
			childWrappers [dirName] = subDir
		}

		return FileWrapper (directoryWithFileWrappers: childWrappers)
	}
}
