//
//  DetailedCollectionView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI
import SwiftData

struct CollectionDetailView: View {
    var name: String
    var collection: Collection?
    var albums: [Album]
    @Query private var newAlbums: [Album]
    @State private var showAlbumPicker = false
    @State private var selectedAlbums: Set<Album> = []
    @State private var isDirectlyAdd: Bool = true
    var columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        NavigationStack {
            if albums.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("No album yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .padding(20)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 24){
                        ForEach(albums) { album in
                            AlbumCard(
                                album: album
                            )
                            .frame(width: 140)
                            .scrollTargetLayout()
                        }
                    }
                    .padding()
                    .navigationTitle(name)
                    .navigationBarTitleDisplayMode(.inline)
                }
                .scrollIndicators(.hidden)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        
                        Button {
                            showAlbumPicker = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        
                    }
                }
                .sheet(isPresented: $showAlbumPicker) {
                    AlbumPickerSheet(
                        selectedAlbums: $selectedAlbums,
                        actionTitle: "Save"
                    ) { selected in
                        collection?.albums.append(contentsOf: selected)
                    }
                    .presentationDetents([.large])
                }
            }
        }
    }
    
}
