//
//  THCreateShotSheet.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import SwiftUI

struct THCreateShotSheet: View {
	let character: THCharacter
	let environment: THEnvironment
	let scene: THScene
	
	let onGenerate: (
		_ shotType: THShotType,
		_ cameraSetup: String,
		_ characterPosition: String,
		_ cameraAngle: String,
		_ lensStyle: String,
		_ compositionNotes: String
	) -> Void
	
	@Environment(\.dismiss) private var dismiss
	
	@State private var shotType: THShotType = .mediumCloseUp
	@State private var cameraSetup: String = ""
	@State private var characterPosition: String = ""
	@State private var cameraAngle: String = "Front"
	@State private var lensStyle: String = "Standard 50mm"
	@State private var compositionNotes: String = ""

	init (
		character: THCharacter,
		environment: THEnvironment,
		scene: THScene,
		onGenerate: @escaping (
			_ shotType: THShotType,
			_ cameraSetup: String,
			_ characterPosition: String,
			_ cameraAngle: String,
			_ lensStyle: String,
			_ compositionNotes: String
		) -> Void
	) {
		self.character = character
		self.environment = environment
		self.scene = scene
		self.onGenerate = onGenerate
		
		// Initialize states from scene defaults
		_shotType = State (initialValue: .mediumCloseUp)
		_cameraSetup = State (initialValue: scene.cameraSetup)
		_characterPosition = State (initialValue: scene.characterPosition)
	}

	var body: some View {
		VStack (spacing: 0) {
			HStack {
				VStack (alignment: .leading, spacing: 4) {
					Text ("Create New AI Shot")
						.font (.headline)
					Text ("Configure camera setup and prompt instructions for generation")
						.font (.caption)
						.foregroundStyle (.secondary)
				}
				Spacer ()
				Button {
					dismiss ()
				} label: {
					Image (systemName: "xmark.circle.fill")
						.font (.title2)
						.foregroundStyle (.secondary)
				}
				.buttonStyle (.plain)
			}
			.padding (16)
			
			Divider ()
			
			Form {
				Section ("Camera Properties") {
					Picker ("Shot Type (Framing)", selection: $shotType) {
						ForEach (THShotType.allCases) { type in
							Text (type.displayName).tag (type)
						}
					}
					
					TextField ("Camera Angle", text: $cameraAngle)
					TextField ("Lens Style", text: $lensStyle)
					TextField ("Composition Notes", text: $compositionNotes)
				}
				
				Section ("AI Prompt Customization") {
					VStack (alignment: .leading, spacing: 6) {
						Text ("Camera Setup Description (Prompt)")
							.font (.caption.bold ())
							.foregroundStyle (.secondary)
						TextEditor (text: $cameraSetup)
							.frame (minHeight: 60)
							.padding (4)
							.background (Color.primary.opacity (0.04))
							.cornerRadius (6)
					}
					
					VStack (alignment: .leading, spacing: 6) {
						Text ("Character Position (Prompt)")
							.font (.caption.bold ())
							.foregroundStyle (.secondary)
						TextEditor (text: $characterPosition)
							.frame (minHeight: 60)
							.padding (4)
							.background (Color.primary.opacity (0.04))
							.cornerRadius (6)
					}
				}
			}
			.formStyle (.grouped)
			
			Divider ()
			
			HStack (spacing: 12) {
				Button ("Cancel") {
					dismiss ()
				}
				.keyboardShortcut (.cancelAction)
				
				Spacer ()
				
				Button ("Generate Shot") {
					onGenerate (
						shotType,
						cameraSetup,
						characterPosition,
						cameraAngle,
						lensStyle,
						compositionNotes
					)
					dismiss ()
				}
				.buttonStyle (.borderedProminent)
				.keyboardShortcut (.defaultAction)
			}
			.padding (16)
		}
		.frame (minWidth: 500, minHeight: 520)
	}
}
