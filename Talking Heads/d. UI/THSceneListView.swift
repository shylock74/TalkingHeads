//
//  THSceneListView.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import SwiftUI

// MARK: - Scene List View

/// Content column view showing a list of scenes with add/remove controls.
/// Creating a scene requires at least one character and one environment to exist.
struct THSceneListView: View {
	@Binding var scenes: [THScene]
	let characters: [THCharacter]
	let environments: [THEnvironment]
	let shots: [THShot]
	@Binding var selectedId: UUID?

	@State private var showingNewSceneSheet = false

	var body: some View {
		VStack (spacing: 0) {
			List (selection: $selectedId) {
				ForEach (scenes) { scene in
					sceneRow (scene)
						.tag (scene.id as UUID?)
						.onTapGesture {
							selectedId = scene.id
						}
				}
				.onDelete (perform: deleteScenes)
			}
			.listStyle (.inset)
			.overlay {
				if scenes.isEmpty {
					emptyStateView
				}
			}

			Divider ()

			HStack {
				Button {
					if canCreateScene {
						showingNewSceneSheet = true
					}
				} label: {
					Image (systemName: "plus")
				}
				.buttonStyle (.plain)
				.disabled (!canCreateScene)
				.padding (8)
				Spacer ()
			}
			.background (.background)
		}
		.sheet (isPresented: $showingNewSceneSheet) {
			THNewSceneSheet (
				characters: characters,
				environments: environments
			) { name, characterId, environmentId, aspectRatio in
				addScene (name: name, characterId: characterId, environmentId: environmentId, aspectRatio: aspectRatio)
			}
		}
	}

	// MARK: - Row

	private func sceneRow (_ scene: THScene) -> some View {
		VStack (alignment: .leading, spacing: 4) {
			Text (scene.name)
				.font (.headline)
			HStack (spacing: 8) {
				if let character = characters.first (where: { $0.id == scene.characterId }) {
					Label (character.name, systemImage: "person.fill")
						.font (.caption)
						.foregroundStyle (.secondary)
				}
				if let environment = environments.first (where: { $0.id == scene.environmentId }) {
					Label (environment.name, systemImage: "photo")
						.font (.caption)
						.foregroundStyle (.secondary)
				}
				Label (scene.aspectRatio.displayName, systemImage: "aspectratio")
					.font (.caption)
					.foregroundStyle (.secondary)
			}

			// Pipeline status indicators
			HStack (spacing: 12) {
				statusBadge (
					icon: "waveform",
					label: "Audio",
					isComplete: scene.audioSequence != nil
				)
				statusBadge (
					icon: "text.alignleft",
					label: "Transcript",
					isComplete: scene.transcript != nil
				)
				statusBadge (
					icon: "camera",
					label: "Shots",
					isComplete: shots.contains (where: { scene.shotIds.contains ($0.id) && $0.isApproved })
				)
				statusBadge (
					icon: "film",
					label: "Render",
					isComplete: scene.renderedVideoPath != nil
				)
			}
		}
		.padding (.vertical, 2)
		.contentShape (Rectangle ())
	}

	private func statusBadge (icon: String, label: String, isComplete: Bool) -> some View {
		HStack (spacing: 3) {
			Image (systemName: icon)
				.font (.caption2)
			Text (label)
				.font (.caption2)
		}
		.foregroundStyle (isComplete ? Color.green : Color.gray.opacity (0.4))
	}

	// MARK: - Empty State

	private var emptyStateView: some View {
		VStack (spacing: 12) {
			Image (systemName: "film.stack")
				.font (.system (size: 40))
				.foregroundStyle (.quaternary)
			Text ("No Scenes")
				.font (.title3)
				.foregroundStyle (.secondary)
			if canCreateScene {
				Text ("Create a scene to start the pipeline")
					.font (.caption)
					.foregroundStyle (.tertiary)
				Button ("Create Scene") {
					showingNewSceneSheet = true
				}
				.buttonStyle (.borderedProminent)
				.controlSize (.small)
			} else {
				Text ("Add a character and an environment first")
					.font (.caption)
					.foregroundStyle (.tertiary)
			}
		}
	}

	// MARK: - Helpers

	private var canCreateScene: Bool {
		!characters.isEmpty && !environments.isEmpty
	}

	private func addScene (name: String, characterId: UUID, environmentId: UUID, aspectRatio: THAspectRatio) {
		let newScene = THScene (
			name: name,
			characterId: characterId,
			environmentId: environmentId,
			aspectRatio: aspectRatio
		)
		scenes.append (newScene)
		selectedId = newScene.id
	}

	private func deleteScenes (at offsets: IndexSet) {
		let idsToDelete = offsets.map { scenes [$0].id }
		scenes.remove (atOffsets: offsets)
		if let selectedId, idsToDelete.contains (selectedId) {
			self.selectedId = nil
		}
	}
}

// MARK: - New Scene Sheet

/// Sheet for creating a new scene with name, character, environment, and aspect ratio selection.
struct THNewSceneSheet: View {
	let characters: [THCharacter]
	let environments: [THEnvironment]
	let onCreate: (String, UUID, UUID, THAspectRatio) -> Void

	@Environment(\.dismiss) private var dismiss
	@State private var name = "Untitled Scene"
	@State private var selectedCharacterId: UUID?
	@State private var selectedEnvironmentId: UUID?
	@State private var selectedAspectRatio: THAspectRatio = .ar_16_9

	var body: some View {
		VStack (spacing: 20) {
			Text ("New Scene")
				.font (.title2.bold ())

			VStack (alignment: .leading, spacing: 12) {
				THEditorField (label: "Scene Name", text: $name)

				VStack (alignment: .leading, spacing: 4) {
					Text ("Character")
						.font (.caption)
						.foregroundStyle (.secondary)
					Picker ("Character", selection: $selectedCharacterId) {
						Text ("Select…").tag (nil as UUID?)
						ForEach (characters) { character in
							Text (character.name).tag (character.id as UUID?)
						}
					}
					.labelsHidden ()
				}

				VStack (alignment: .leading, spacing: 4) {
					Text ("Environment")
						.font (.caption)
						.foregroundStyle (.secondary)
					Picker ("Environment", selection: $selectedEnvironmentId) {
						Text ("Select…").tag (nil as UUID?)
						ForEach (environments) { environment in
							Text (environment.name).tag (environment.id as UUID?)
						}
					}
					.labelsHidden ()
				}

				VStack (alignment: .leading, spacing: 4) {
					Text ("Aspect Ratio")
						.font (.caption)
						.foregroundStyle (.secondary)
					Picker ("Aspect Ratio", selection: $selectedAspectRatio) {
						ForEach (THAspectRatio.allCases) { ratio in
							Text (ratio.displayName).tag (ratio)
						}
					}
					.labelsHidden ()
				}
			}

			HStack {
				Button ("Cancel") {
					dismiss ()
				}
				.keyboardShortcut (.cancelAction)

				Spacer ()

				Button ("Create") {
					if let charId = selectedCharacterId,
					   let envId = selectedEnvironmentId {
						onCreate (name, charId, envId, selectedAspectRatio)
						dismiss ()
					}
				}
				.keyboardShortcut (.defaultAction)
				.disabled (selectedCharacterId == nil || selectedEnvironmentId == nil)
			}
		}
		.padding (24)
		.frame (minWidth: 380)
		.onAppear {
			selectedCharacterId = characters.first?.id
			selectedEnvironmentId = environments.first?.id
		}
	}
}
