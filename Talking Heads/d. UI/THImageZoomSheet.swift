//
//  THImageZoomSheet.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import SwiftUI

struct THImageZoomSheet: View {
	let imagePath: String?
	let shot: THShot?
	let projectURL: URL?
	
	@Environment(\.dismiss) private var dismiss

	init (imagePath: String, projectURL: URL?) {
		self.imagePath = imagePath
		self.shot = nil
		self.projectURL = projectURL
	}

	init (shot: THShot, projectURL: URL?) {
		self.imagePath = nil
		self.shot = shot
		self.projectURL = projectURL
	}

	var body: some View {
		VStack (spacing: 0) {
			HStack {
				VStack (alignment: .leading, spacing: 4) {
					if let shot = shot {
						Text ("Shot Variations Preview")
							.font (.headline)
						Text (shot.promptUsed)
							.font (.caption)
							.foregroundStyle (.secondary)
							.lineLimit (1)
					} else if let imagePath = imagePath {
						Text (URL (fileURLWithPath: imagePath).lastPathComponent)
							.font (.headline)
						Text (imagePath)
							.font (.caption)
							.foregroundStyle (.secondary)
							.lineLimit (1)
					}
				}
				Spacer ()
				Button {
					dismiss ()
				} label: {
					Image (systemName: "xmark.circle.fill")
						.font (.title)
						.foregroundStyle (.secondary)
				}
				.buttonStyle (.plain)
			}
			.padding (16)
			
			Divider ()
			
			if let shot = shot {
				ScrollView {
					Grid (horizontalSpacing: 20, verticalSpacing: 20) {
						GridRow {
							variantCell (title: "Mouth Closed / Eyes Open (Base)", path: shot.variants.mouthClosedEyesOpen)
							variantCell (title: "Mouth Open / Eyes Open", path: shot.variants.mouthOpenEyesOpen)
						}
						GridRow {
							variantCell (title: "Mouth Closed / Eyes Closed", path: shot.variants.mouthClosedEyesClosed)
							variantCell (title: "Mouth Open / Eyes Closed", path: shot.variants.mouthOpenEyesClosed)
						}
					}
					.padding (24)
				}
			} else if let imagePath = imagePath {
				let resolvedURL = resolveURL (imagePath)
				if let nsImage = NSImage (contentsOf: resolvedURL) {
					Image (nsImage: nsImage)
						.resizable ()
						.aspectRatio (contentMode: .fit)
						.padding (24)
						.frame (maxWidth: .infinity, maxHeight: .infinity)
				} else {
					errorLoadingView (path: imagePath)
						.frame (maxWidth: .infinity, maxHeight: .infinity)
				}
			}
		}
		.frame (minWidth: shot != nil ? 800 : 600, minHeight: shot != nil ? 650 : 600)
	}

	// MARK: - Helper Views & Methods

	@ViewBuilder
	private func variantCell (title: String, path: String?) -> some View {
		VStack (alignment: .leading, spacing: 8) {
			Text (title)
				.font (.subheadline.bold ())
				.foregroundStyle (.secondary)
			
			ZStack {
				RoundedRectangle (cornerRadius: 10)
					.fill (Color.primary.opacity (0.04))
					.aspectRatio (16 / 9, contentMode: .fit)
				
				if let path = path {
					let url = resolveURL (path)
					if let nsImage = NSImage (contentsOf: url) {
						Image (nsImage: nsImage)
							.resizable ()
							.aspectRatio (contentMode: .fit)
							.clipShape (RoundedRectangle (cornerRadius: 10))
					} else {
						errorLoadingView (path: path)
					}
				} else {
					// Dotted placeholder
					RoundedRectangle (cornerRadius: 10)
						.strokeBorder (style: StrokeStyle (lineWidth: 2, dash: [5]))
						.foregroundStyle (.quaternary)
						.aspectRatio (16 / 9, contentMode: .fit)
						.overlay {
							VStack (spacing: 8) {
								Image (systemName: "sparkles")
									.font (.title)
									.foregroundStyle (.tertiary)
								Text ("Not Generated Yet")
									.font (.caption.bold ())
									.foregroundStyle (.secondary)
								Text ("Approve shot to generate variants")
									.font (.system (size: 9))
									.foregroundStyle (.tertiary)
							}
						}
				}
			}
			.frame (maxWidth: .infinity)
		}
	}

	@ViewBuilder
	private func errorLoadingView (path: String) -> some View {
		VStack (spacing: 12) {
			Image (systemName: "exclamationmark.triangle.fill")
				.font (.title2)
				.foregroundStyle (.red)
			Text ("Failed to load image")
				.font (.caption.bold ())
			Text (path)
				.font (.system (size: 9).monospaced ())
				.foregroundStyle (.secondary)
				.lineLimit (1)
		}
		.padding (12)
	}

	private func resolveURL (_ path: String) -> URL {
		if path.hasPrefix ("/") {
			return URL (fileURLWithPath: path)
		} else if let projectURL = projectURL {
			return THFileUtils.resolveAssetPath (path, projectURL: projectURL)
		} else {
			return URL (fileURLWithPath: path)
		}
	}
}
