//
//  ContentView.swift
//  Talking Heads
//
//  Created by Alex Raccuglia on 12/06/2026.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: Talking_HeadsDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(Talking_HeadsDocument()))
}
