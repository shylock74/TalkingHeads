//
//  Talking_HeadsApp.swift
//  Talking Heads
//
//  Created by Alex Raccuglia on 12/06/2026.
//

import SwiftUI

@main
struct Talking_HeadsApp: App {
	var body: some Scene {
		DocumentGroup (newDocument: Talking_HeadsDocument ()) { file in
			ContentView (document: file.$document, projectURL: file.fileURL)
		}
		.commands {
			// Remove default "New Window" command
			CommandGroup (replacing: .newItem) {
				Button ("New Project") {
					NSDocumentController.shared.newDocument (nil)
				}
				.keyboardShortcut ("n", modifiers: .command)

				Button ("Open Project…") {
					NSDocumentController.shared.openDocument (nil)
				}
				.keyboardShortcut ("o", modifiers: .command)
			}
		}

		Settings {
			THPreferencesView ()
		}
	}
}
