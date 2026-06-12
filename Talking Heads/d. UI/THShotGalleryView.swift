//
//  THShotGalleryView.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import SwiftUI
import UMUIControls

// MARK: - Shot Gallery View

/// A grid view displaying generated shots for a scene.
/// Each shot card shows the 4 image variants and an approve/reject toggle.
/// Placeholder for Slice 3 — currently shows the shell with no generation capability.
struct THShotGalleryView: View {
	let shots: [THShot]
	let onApprove: (UUID, Bool) -> Void
	let onDelete: (UUID) -> Void

	private let columns = [
		GridItem (.adaptive (minimum: 200, maximum: 300), spacing: 16)
	]

	var body: some View {
		ScrollView {
			if shots.isEmpty {
				emptyStateView
			} else {
				LazyVGrid (columns: columns, spacing: 16) {
					ForEach (shots) { shot in
						shotCard (shot)
					}
				}
				.padding (16)
			}
		}
	}

	// MARK: - Shot Card

	private func shotCard (_ shot: THShot) -> some View {
		VStack (spacing: 8) {
			// Image preview area
			ZStack {
				RoundedRectangle (cornerRadius: 10)
					.fill (Color.primary.opacity (0.05))
					.aspectRatio (16 / 9, contentMode: .fit)

				if let mainPath = shot.variants.mouthClosedEyesOpen,
				   let nsImage = NSImage (contentsOfFile: mainPath) {
					Image (nsImage: nsImage)
						.resizable ()
						.aspectRatio (contentMode: .fill)
						.clipShape (RoundedRectangle (cornerRadius: 10))
				} else {
					VStack (spacing: 4) {
						Image (systemName: "camera")
							.font (.title2)
							.foregroundStyle (.quaternary)
						Text (shot.shotType.abbreviation)
							.font (.caption.bold ())
							.foregroundStyle (.tertiary)
					}
				}
			}
			.overlay (alignment: .topLeading) {
				Text (shot.shotType.displayName)
					.font (.caption2.bold ())
					.foregroundStyle (.white)
					.padding (.horizontal, 6)
					.padding (.vertical, 2)
					.background (Capsule ().fill (.black.opacity (0.6)))
					.padding (6)
			}
			.overlay (alignment: .topTrailing) {
				// Variants indicator
				HStack (spacing: 2) {
					ForEach (0..<4, id: \.self) { i in
						Circle ()
							.fill (i < shot.variants.generatedCount ? Color.green : Color.gray.opacity (0.3))
							.frame (width: 6, height: 6)
					}
				}
				.padding (8)
			}

			// Controls
			HStack {
				Text (shot.cameraAngle)
					.font (.caption)
					.foregroundStyle (.secondary)
					.lineLimit (1)

				Spacer ()

				Button {
					onApprove (shot.id, !shot.isApproved)
				} label: {
					Image (systemName: shot.isApproved ? "checkmark.circle.fill" : "checkmark.circle")
						.foregroundStyle (shot.isApproved ? .green : .secondary)
				}
				.buttonStyle (.plain)

				Button {
					onDelete (shot.id)
				} label: {
					Image (systemName: "trash")
						.foregroundStyle (.secondary)
				}
				.buttonStyle (.plain)
			}
		}
		.padding (8)
		.background (
			RoundedRectangle (cornerRadius: 12)
				.fill (.background)
				.shadow (color: .black.opacity (0.08), radius: 4, y: 2)
		)
	}

	// MARK: - Empty State

	private var emptyStateView: some View {
		VStack (spacing: 12) {
			Image (systemName: "camera.viewfinder")
				.font (.system (size: 48))
				.foregroundStyle (.quaternary)
			Text ("No Shots Generated")
				.font (.title3)
				.foregroundStyle (.secondary)
			Text ("Generate shots from the Scene Editor")
				.font (.caption)
				.foregroundStyle (.tertiary)
		}
		.frame (maxWidth: .infinity, maxHeight: .infinity)
		.padding (40)
	}
}
