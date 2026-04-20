//
//  ContentView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 16/04/26.
//

import SwiftUI
import SwiftData

enum Tab {
    case camera
    case collection
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedTab: Tab = .camera
    @StateObject private var camera = CameraManager()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CameraView(camera: camera)
                .tag(Tab.camera)
                .tabItem {
                    Label("Camera", systemImage: "camera.fill")
                }
            
            CollectionView()
                .tag(Tab.collection)
                .tabItem {
                    Label("Collection", systemImage: "photo.stack")
                }
        }
        .onAppear {
            if selectedTab == .camera {
                camera.setup()
            }
        }
        .onChange(of: selectedTab) { _, tab in
            switch tab {
            case .camera:
                camera.setup()
            default:
                camera.stopSession()
            }
        }
    }
}

#Preview {
    ContentView()
}
