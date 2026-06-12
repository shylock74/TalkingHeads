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
        DocumentGroup(newDocument: Talking_HeadsDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
