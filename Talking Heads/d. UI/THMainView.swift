//
//  THMainView.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import SwiftUI

// MARK: - Main View

/// Root view of the application, using a three-column NavigationSplitView.
/// - Sidebar: section list (Characters, Environments, Scenes)
/// - Content: item list for selected section
/// - Detail: editor for selected item
struct THMainView: View {
	@Binding var document: Talking_HeadsDocument
	let projectURL: URL?

	@State private var selectedSection: THSidebarSection = .characters
	@State private var selectedCharacterId: UUID?
	@State private var selectedEnvironmentId: UUID?
	@State private var selectedSceneId: UUID?

	var body: some View {
		HSplitView {
			sidebarContent
				.frame (minWidth: 150, idealWidth: 200, maxWidth: 300)
				.layoutPriority (1)
			contentColumn
				.frame (minWidth: 250, idealWidth: 320, maxWidth: 450)
				.layoutPriority (2)
			detailColumn
				.frame (minWidth: 400, idealWidth: 600, maxWidth: .infinity)
				.layoutPriority (3)
		}
		.frame (minWidth: 1000, minHeight: 600)
	}

	// MARK: - Sidebar

	@ViewBuilder
	private var sidebarContent: some View {
		List (selection: $selectedSection) {
			ForEach (THSidebarSection.allCases) { section in
				Label {
					Text (section.displayName)
				} icon: {
					Image (systemName: section.iconName)
				}
				.tag (section)
				.contentShape (Rectangle ())
				.onTapGesture {
					selectedSection = section
				}
				.badge (badgeCount (for: section))
			}
		}
		.listStyle (.sidebar)
	}

	// MARK: - Content Column

	@ViewBuilder
	private var contentColumn: some View {
		switch selectedSection {
		case .characters:
			THCharacterListView (
				characters: $document.projectState.characters,
				selectedId: $selectedCharacterId
			)
		case .environments:
			THEnvironmentListView (
				environments: $document.projectState.environments,
				selectedId: $selectedEnvironmentId
			)
		case .scenes:
			THSceneListView (
				scenes: $document.projectState.scenes,
				characters: document.projectState.characters,
				environments: document.projectState.environments,
				shots: document.projectState.shots,
				selectedId: $selectedSceneId
			)
		}
	}

	// MARK: - Detail Column

	@ViewBuilder
	private var detailColumn: some View {
		switch selectedSection {
		case .characters:
			if let selectedId = selectedCharacterId,
			   let index = document.projectState.characters.firstIndex (where: { $0.id == selectedId }) {
				THCharacterEditorView (
					character: $document.projectState.characters [index]
				)
			} else {
				emptyDetailView (message: "Select a character to edit")
			}

		case .environments:
			if let selectedId = selectedEnvironmentId,
			   let index = document.projectState.environments.firstIndex (where: { $0.id == selectedId }) {
				THEnvironmentEditorView (
					environment: $document.projectState.environments [index]
				)
			} else {
				emptyDetailView (message: "Select an environment to edit")
			}

		case .scenes:
			if let selectedId = selectedSceneId,
			   let index = document.projectState.scenes.firstIndex (where: { $0.id == selectedId }) {
				THSceneEditorView (
					scene: $document.projectState.scenes [index],
					document: $document,
					projectURL: projectURL
				)
			} else {
				emptyDetailView (message: "Select a scene to edit")
			}
		}
	}

	// MARK: - Helpers

	private func badgeCount (for section: THSidebarSection) -> Int {
		switch section {
		case .characters:	return document.projectState.characters.count
		case .environments:	return document.projectState.environments.count
		case .scenes:		return document.projectState.scenes.count
		}
	}

	private func emptyDetailView (message: String) -> some View {
		VStack (spacing: 12) {
			Image (systemName: "film.stack")
				.font (.system (size: 48))
				.foregroundStyle (.quaternary)
			Text (message)
				.font (.title3)
				.foregroundStyle (.secondary)
		}
		.frame (maxWidth: .infinity, maxHeight: .infinity)
	}
}
