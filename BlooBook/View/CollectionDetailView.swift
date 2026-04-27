//
//  DetailedCollectionView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI
import SwiftData

struct CollectionDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var name: String
    var collection: AlbumCollection?
    var albums: [Album] = []
    @State private var showAlbumPicker = false
    @State private var selectedAlbums: Set<Album> = []
    @State private var showDeleteConfirmation = false
    var columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    private var displayedAlbums: [Album] {
        if let collection {
            return collection.albums
        }

        return albums
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if displayedAlbums.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "rectangle.stack")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.6))
                        
                        Text("This collection is empty")
                            .font(.headline)
                        
                        Text("Add albums to start organizing this collection.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(24)
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(displayedAlbums) { album in
                                AlbumCard(
                                    album: album
                                )
                                .frame(width: 140)
                                .scrollTargetLayout()
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(name)
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.hidden)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            openAlbumPicker()
                        } label: {
                            Label("Manage Albums", systemImage: "pencil")
                        }
                        
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Collection", systemImage: "trash.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .sheet(isPresented: $showAlbumPicker) {
                AlbumPickerSheet(
                    selectedAlbums: $selectedAlbums,
                    actionTitle: "Save"
                ) { selected in
                    guard let collection else { return }
                    collection.albums = collection.albums.filter { selected.contains($0) }
                    for album in selected where !collection.albums.contains(album) {
                        collection.albums.append(album)
                    }
                    selectedAlbums = Set(collection.albums)
                }
                .presentationDetents([.large])
            }
            .confirmationDialog("Delete this collection?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    if let collection = collection {
                        deleteCollection(collection)
                    }
                }
            }
        }
    }
    
    func deleteCollection(_ collection: AlbumCollection) {
        withAnimation {
            context.delete(collection)
        }
        
        dismiss()
    }

    func openAlbumPicker() {
        selectedAlbums = Set(collection?.albums ?? [])
        showAlbumPicker = true
    }
}
