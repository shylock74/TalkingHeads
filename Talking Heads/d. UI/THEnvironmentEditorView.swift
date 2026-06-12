//
//  THEnvironmentEditorView.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import SwiftUI
import UniformTypeIdentifiers
import UMUIControls

// MARK: - Environment Editor View

/// Detail view for editing a single environment's properties.
/// Organized into sections: Identity, Visual Style, Lighting, Atmosphere, References.
struct THEnvironmentEditorView: View {
	@Binding var environment: THEnvironment
	@State private var isImportingImages = false

	var body: some View {
		ScrollView {
			VStack (alignment: .leading, spacing: 20) {
				headerSection
				identitySection
				visualStyleSection
				lightingSection
				atmosphereSection
				referenceImagesSection
				promptPreviewSection
			}
			.padding (24)
		}
		.navigationTitle (environment.name)
		.fileImporter (
			isPresented: $isImportingImages,
			allowedContentTypes: [.image],
			allowsMultipleSelection: true
		) { result in
			handleImageImport (result)
		}
	}

	// MARK: - Header

	private var headerSection: some View {
		VStack (alignment: .leading, spacing: 8) {
			Text ("Environment Sheet")
				.font (.title2.bold ())
				.foregroundStyle (.primary)
			Text ("Define the environment for consistent visual generation")
				.font (.subheadline)
				.foregroundStyle (.secondary)
		}
	}

	// MARK: - Identity

	private var identitySection: some View {
		UMUISection ("Identity") {
			VStack (alignment: .leading, spacing: 12) {
				THEditorField (label: "Name", text: $environment.name)
				THEditorField (label: "Description", text: $environment.description, axis: .vertical)

				HStack (spacing: 12) {
					VStack (alignment: .leading, spacing: 4) {
						Text ("Category")
							.font (.caption)
							.foregroundStyle (.secondary)
						Picker ("Category", selection: $environment.category) {
							ForEach (THEnvironmentCategory.allCases) { category in
								Text (category.displayName).tag (category)
							}
						}
						.labelsHidden ()
					}
					THEditorField (label: "Subcategory", text: $environment.subcategory)
				}
			}
		}
	}

	// MARK: - Visual Style

	private var visualStyleSection: some View {
		UMUISection ("Visual Style") {
			VStack (alignment: .leading, spacing: 12) {
				HStack (spacing: 12) {
					THEditorField (label: "Architectural Style", text: $environment.visualStyle.architecturalStyle)
					THEditorField (label: "Visual Style", text: $environment.visualStyle.visualStyle)
				}
				HStack (spacing: 12) {
					THEditorField (label: "Dominant Palette", text: $environment.visualStyle.dominantPalette)
					THEditorField (label: "Materials", text: $environment.visualStyle.materials)
				}
				THEditorField (label: "Detail Level", text: $environment.visualStyle.detailLevel)
			}
		}
	}

	// MARK: - Lighting

	private var lightingSection: some View {
		UMUISection ("Lighting") {
			VStack (alignment: .leading, spacing: 12) {
				HStack (spacing: 12) {
					THEditorField (label: "Time of Day", text: $environment.lighting.timeOfDay)
					THEditorField (label: "Season", text: $environment.lighting.season)
				}
				HStack (spacing: 12) {
					THEditorField (label: "Weather", text: $environment.lighting.weather)
					THEditorField (label: "Lighting Type", text: $environment.lighting.lightingType)
				}
				THEditorField (label: "Color Temperature", text: $environment.lighting.colorTemperature)
			}
		}
	}

	// MARK: - Atmosphere

	private var atmosphereSection: some View {
		UMUISection ("Atmosphere") {
			VStack (alignment: .leading, spacing: 12) {
				THEditorField (label: "Mood", text: $environment.atmosphere.mood)
				THEditorField (label: "Activity Level", text: $environment.atmosphere.activityLevel)
				THEditorField (label: "Notes", text: $environment.notes, axis: .vertical)
			}
		}
	}

	// MARK: - Reference Images

	private var referenceImagesSection: some View {
		UMUISection ("Reference Images") {
			VStack (alignment: .leading, spacing: 12) {
				if environment.referenceImagePaths.isEmpty {
					HStack {
						Image (systemName: "photo.on.rectangle.angled")
							.foregroundStyle (.quaternary)
						Text ("No reference images added")
							.font (.caption)
							.foregroundStyle (.tertiary)
						Spacer ()
					}
					.padding (.vertical, 8)
				} else {
					ScrollView (.horizontal, showsIndicators: false) {
						HStack (spacing: 8) {
							ForEach (environment.referenceImagePaths, id: \.self) { path in
								referenceImageThumbnail (path: path)
							}
						}
					}
				}

				Button {
					isImportingImages = true
				} label: {
					Label ("Add Reference Images", systemImage: "plus.circle")
				}
				.controlSize (.small)
			}
		}
	}

	// MARK: - Prompt Preview

	private var promptPreviewSection: some View {
		UMUISection ("Prompt Preview") {
			VStack (alignment: .leading, spacing: 8) {
				Text ("Generated prompt base:")
					.font (.caption)
					.foregroundStyle (.secondary)
				Text (environment.promptSummary)
					.font (.system (.caption, design: .monospaced))
					.foregroundStyle (.primary)
					.padding (8)
					.frame (maxWidth: .infinity, alignment: .leading)
					.background (Color.primary.opacity (0.04))
					.clipShape (RoundedRectangle (cornerRadius: 6))
			}
		}
	}

	// MARK: - Image Thumbnail

	private func referenceImageThumbnail (path: String) -> some View {
		ZStack {
			RoundedRectangle (cornerRadius: 8)
				.fill (Color.primary.opacity (0.05))
				.frame (width: 80, height: 80)

			if let nsImage = NSImage (contentsOfFile: path) {
				Image (nsImage: nsImage)
					.resizable ()
					.aspectRatio (contentMode: .fill)
					.frame (width: 80, height: 80)
					.clipShape (RoundedRectangle (cornerRadius: 8))
			} else {
				Image (systemName: "photo")
					.foregroundStyle (.quaternary)
			}
		}
		.overlay (alignment: .topTrailing) {
			Button {
				environment.referenceImagePaths.removeAll { $0 == path }
			} label: {
				Image (systemName: "xmark.circle.fill")
					.font (.caption)
					.foregroundStyle (.secondary)
			}
			.buttonStyle (.plain)
			.padding (2)
		}
	}

	// MARK: - Image Import Handler

	private func handleImageImport (_ result: Result<[URL], Error>) {
		guard case .success (let urls) = result else { return }
		for url in urls {
			environment.referenceImagePaths.append (url.path)
		}
		environment.modifiedAt = Date ()
	}
}
