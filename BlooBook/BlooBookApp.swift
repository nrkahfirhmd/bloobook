//
//  BlooBookApp.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 16/04/26.
//

import SwiftUI
import SwiftData

@main
struct BlooBookApp: App {
    @Environment(\.modelContext) var context
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Memory.self,
            Photo.self,
            Album.self,
            AlbumCollection.self,
            Sticker.self,
            CanvasText.self
        ])
    }
}
