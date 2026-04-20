//
//  DetailedCollectionView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI
import SwiftData

struct CollectionDetailView: View {
    var collection: String
    var albums: [Album]
    @Query private var newAlbums: [Album]
    @State private var showAlbumPicker = false
    @State private var selectedAlbums: Set<Album> = []
    
    var columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        
        NavigationStack {
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
                .navigationTitle(collection)
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
                AlbumPickerSheet(albums: newAlbums, selectedAlbums: $selectedAlbums)
                    .presentationDetents([.large])
            }
        }
    }
}
