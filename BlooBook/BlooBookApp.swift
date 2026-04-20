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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Memory.self,
            Photo.self,
            Album.self,
            Collection.self
        ])
    }
}
