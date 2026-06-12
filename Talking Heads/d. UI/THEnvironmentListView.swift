//
//  THEnvironmentListView.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import SwiftUI

// MARK: - Environment List View

/// Content column view showing a list of environments with add/remove controls.
struct THEnvironmentListView: View {
	@Binding var environments: [THEnvironment]
	@Binding var selectedId: UUID?

	var body: some View {
		VStack (spacing: 0) {
			List (selection: $selectedId) {
				ForEach (environments) { environment in
					environmentRow (environment)
						.tag (environment.id as UUID?)
						.onTapGesture {
							selectedId = environment.id
						}
				}
				.onDelete (perform: deleteEnvironments)
			}
			.listStyle (.inset)
			.overlay {
				if environments.isEmpty {
					emptyStateView
				}
			}

			Divider ()

			HStack {
				Button {
					addEnvironment ()
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

	private func environmentRow (_ environment: THEnvironment) -> some View {
		VStack (alignment: .leading, spacing: 4) {
			Text (environment.name)
				.font (.headline)
			HStack (spacing: 8) {
				Text (environment.category.displayName)
					.font (.caption)
					.foregroundStyle (.secondary)
				if !environment.subcategory.isEmpty {
					Text ("• \(environment.subcategory)")
						.font (.caption)
						.foregroundStyle (.secondary)
				}
			}
			if !environment.atmosphere.mood.isEmpty {
				Text (environment.atmosphere.mood)
					.font (.caption2)
					.foregroundStyle (.tertiary)
			}
		}
		.padding (.vertical, 2)
		.contentShape (Rectangle ())
	}

	// MARK: - Empty State

	private var emptyStateView: some View {
		VStack (spacing: 12) {
			Image (systemName: "photo.on.rectangle.angled")
				.font (.system (size: 40))
				.foregroundStyle (.quaternary)
			Text ("No Environments")
				.font (.title3)
				.foregroundStyle (.secondary)
			Text ("Add an environment to get started")
				.font (.caption)
				.foregroundStyle (.tertiary)
			Button ("Add Environment") {
				addEnvironment ()
			}
			.buttonStyle (.borderedProminent)
			.controlSize (.small)
		}
	}

	// MARK: - Actions

	private func addEnvironment () {
		let newEnvironment = THEnvironment ()
		environments.append (newEnvironment)
		selectedId = newEnvironment.id
	}

	private func deleteEnvironments (at offsets: IndexSet) {
		let idsToDelete = offsets.map { environments [$0].id }
		environments.remove (atOffsets: offsets)
		if let selectedId, idsToDelete.contains (selectedId) {
			self.selectedId = nil
		}
	}
}
