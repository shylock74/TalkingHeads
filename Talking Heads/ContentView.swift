//
//  ContentView.swift
//  Talking Heads
//
//  Created by Alex Raccuglia on 12/06/2026.
//

import SwiftUI

struct ContentView: View {
	@Binding var document: Talking_HeadsDocument
	let projectURL: URL?

	var body: some View {
		THMainView (document: $document, projectURL: projectURL)
	}
}

#Preview {
	ContentView (document: .constant (Talking_HeadsDocument ()), projectURL: nil)
}
