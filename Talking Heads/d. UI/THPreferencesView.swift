//
//  THPreferencesView.swift
//  Talking Heads
//
//  Created by Antigravity on 12/06/2026.
//

import SwiftUI

/// Preferences window content for configuring global settings like the Gemini API Key.
struct THPreferencesView: View {
	@AppStorage("UMGeminiAPIKey") private var apiKey = ""
	
	var body: some View {
		VStack (alignment: .leading, spacing: 20) {
			Text ("Talking Heads Preferences")
				.font (.title2.bold ())
			
			Divider ()
			
			VStack (alignment: .leading, spacing: 6) {
				Text ("Gemini API Key")
					.font (.headline)
				
				SecureField ("AIzaSy...", text: $apiKey)
					.textFieldStyle (.roundedBorder)
					.font (.system (.body, design: .monospaced))
				
				Text ("Get your API key from [aistudio.google.com/apikey](https://aistudio.google.com/apikey)")
					.font (.caption)
					.foregroundStyle (.secondary)
			}
			
			Spacer ()
		}
		.padding (24)
		.frame (width: 480, height: 200)
	}
}

#Preview {
	THPreferencesView ()
}
