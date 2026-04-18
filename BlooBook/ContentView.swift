//
//  ContentView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 16/04/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            Tab("Camera", systemImage: "camera.fill"){
                CameraView()
            }
            Tab("Collection", systemImage: "photo.stack"){
                CollectionView()
            }
        }
    }
}

#Preview {
    ContentView()
}
