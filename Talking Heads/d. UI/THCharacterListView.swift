//
//  THCharacterListView.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import SwiftUI

// MARK: - Character List View

/// Content column view showing a list of characters with add/remove controls.
struct THCharacterListView: View {
	@Binding var characters: [THCharacter]
	@Binding var selectedId: UUID?

	var body: some View {
		VStack (spacing: 0) {
			List (selection: $selectedId) {
				ForEach (characters) { character in
					characterRow (character)
						.tag (character.id as UUID?)
						.onTapGesture {
							selectedId = character.id
						}
				}
				.onDelete (perform: deleteCharacters)
			}
			.listStyle (.inset)
			.overlay {
				if characters.isEmpty {
					emptyStateView
				}
			}

			Divider ()

			HStack {
				Button {
					addCharacter ()
				} label: {
					Image (systemName: "plus")
				}
				.buttonStyle (.plain)
				.padding (8)
				Spacer ()
			}
			.background (.background)
		}
	}

	// MARK: - Row

	private func characterRow (_ character: THCharacter) -> some View {
		VStack (alignment: .leading, spacing: 4) {
			Text (character.name)
				.font (.headline)
			HStack (spacing: 8) {
				if !character.description.profession.isEmpty {
					Text (character.description.profession)
						.font (.caption)
						.foregroundStyle (.secondary)
				}
				if !character.description.age.isEmpty {
					Text ("Age: \(character.description.age)")
						.font (.caption)
						.foregroundStyle (.secondary)
				}
			}
			Text ("\(character.referenceImagePaths.count) reference image(s)")
				.font (.caption2)
				.foregroundStyle (.tertiary)
		}
		.padding (.vertical, 2)
		.contentShape (Rectangle ())
	}

	// MARK: - Empty State

	private var emptyStateView: some View {
		VStack (spacing: 12) {
			Image (systemName: "person.crop.rectangle.badge.plus")
				.font (.system (size: 40))
				.foregroundStyle (.quaternary)
			Text ("No Characters")
				.font (.title3)
				.foregroundStyle (.secondary)
			Text ("Add a character to get started")
				.font (.caption)
				.foregroundStyle (.tertiary)
			Button ("Add Character") {
				addCharacter ()
			}
			.buttonStyle (.borderedProminent)
			.controlSize (.small)
		}
	}

	// MARK: - Actions

	private func addCharacter () {
		let newCharacter = THCharacter ()
		characters.append (newCharacter)
		selectedId = newCharacter.id
	}

	private func deleteCharacters (at offsets: IndexSet) {
		let idsToDelete = offsets.map { characters [$0].id }
		characters.remove (atOffsets: offsets)
		if let selectedId, idsToDelete.contains (selectedId) {
			self.selectedId = nil
		}
	}
}
