//
//  THCharacterEditorView.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import SwiftUI
import UniformTypeIdentifiers
import UMUIControls

// MARK: - Character Editor View

/// Detail view for editing a single character's identity and description.
/// Provides a structured form for all character attributes used in prompt generation.
struct THCharacterEditorView: View {
	@Binding var character: THCharacter
	@State private var isImportingImages = false

	var body: some View {
		ScrollView {
			VStack (alignment: .leading, spacing: 20) {
				headerSection
				identitySection
				appearanceSection
				personalitySection
				referenceImagesSection
				promptPreviewSection
			}
			.padding (24)
		}
		.navigationTitle (character.name)
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
			Text ("Character Sheet")
				.font (.title2.bold ())
				.foregroundStyle (.primary)
			Text ("Define the character's identity for consistent AI generation")
				.font (.subheadline)
				.foregroundStyle (.secondary)
		}
	}

	// MARK: - Identity

	private var identitySection: some View {
		UMUISection ("Identity") {
			VStack (alignment: .leading, spacing: 12) {
				THEditorField (label: "Name", text: $character.name)
				HStack (spacing: 12) {
					THEditorField (label: "Gender", text: $character.description.gender)
					THEditorField (label: "Age", text: $character.description.age)
				}
				THEditorField (label: "Profession", text: $character.description.profession)
				THEditorField (label: "Lifestyle", text: $character.description.lifestyle)
			}
		}
	}

	// MARK: - Appearance

	private var appearanceSection: some View {
		UMUISection ("Appearance") {
			VStack (alignment: .leading, spacing: 12) {
				THEditorField (label: "Physical Appearance", text: $character.description.physicalAppearance, axis: .vertical)
				THEditorField (label: "Clothing Style", text: $character.description.clothingStyle, axis: .vertical)
			}
		}
	}

	// MARK: - Personality

	private var personalitySection: some View {
		UMUISection ("Personality & Notes") {
			VStack (alignment: .leading, spacing: 12) {
				THEditorField (label: "Personality", text: $character.description.personality, axis: .vertical)
				THEditorField (label: "Additional Notes", text: $character.description.additionalNotes, axis: .vertical)
			}
		}
	}

	// MARK: - Reference Images

	private var referenceImagesSection: some View {
		UMUISection ("Reference Images") {
			VStack (alignment: .leading, spacing: 12) {
				if character.referenceImagePaths.isEmpty {
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
							ForEach (character.referenceImagePaths, id: \.self) { path in
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
				Text (character.derivedPromptBase)
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

			// Attempt to load the image
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
				character.referenceImagePaths.removeAll { $0 == path }
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
			// For now, store the absolute path.
			// In Phase 3, THAssetManager will copy into the project directory and store relative paths.
			character.referenceImagePaths.append (url.path)
		}
		character.modifiedAt = Date ()
	}
}

// MARK: - Editor Field (Reusable)

/// A labeled text field for character/environment editor forms.
struct THEditorField: View {
	let label: String
	@Binding var text: String
	var axis: Axis = .horizontal

	var body: some View {
		VStack (alignment: .leading, spacing: 4) {
			Text (label)
				.font (.caption)
				.foregroundStyle (.secondary)
			TextField (label, text: $text, axis: axis)
				.textFieldStyle (.roundedBorder)
				.lineLimit (axis == .vertical ? 3...6 : 1...1)
		}
	}
}
