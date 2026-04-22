//
//  AlbumPickerSheet.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 20/04/26.
//

import SwiftUI
import SwiftData

struct AlbumPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @Query var albums: [Album]
    @Binding var selectedAlbums: Set<Album>
    
    var actionTitle: String = "Done"
    var onSave: ((Set<Album>) -> Void)?
    
    var columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24){
                    ForEach(albums) { album in
                        selectableCard(album)
                            .frame(width: 140)
                    }
                }
                .padding()
            }
            .navigationTitle("Select Albums")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(actionTitle) {
                        onSave?(selectedAlbums)
                        dismiss()
                    }
                }
            }
        }
    }
    
    func selectableCard(_ album: Album) -> some View {
        ZStack(alignment: .topTrailing) {
            AlbumCard(album: album, isSelectable: true)
                .opacity(selectedAlbums.contains(album) ? 0.7 : 1)
            
            if selectedAlbums.contains(album) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .background {
                        Circle().fill(.primary)
                    }
                    .overlay {
                        Circle().stroke(Color.white, lineWidth: 2)
                    }
                    .padding(12)
            }
        }
        .onTapGesture {
            toggle(album)
        }
    }
    
    func toggle(_ album: Album) {
        if selectedAlbums.contains(album) {
            selectedAlbums.remove(album)
        } else {
            selectedAlbums.insert(album)
        }
    }
}
