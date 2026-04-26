//
//  CollectionView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var context
    
    @Query var collections: [AlbumCollection]
    @Query var memories: [Memory]
    @Query var albums: [Album]
    @Query var photos: [Photo]
    
    @State private var showAddCollectionSheet = false
    @State private var showAddBookSheet = false
    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false
    @State private var selectedAlbum: Album?
    @State private var deletedAlbum: Album?
    @State private var selectedMemory: Memory?
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack{
                    VStack(alignment: .leading) {
                        NavigationLink {
                            ShowcaseView()
                        } label: {
                            HStack {
                                Text("All Memories")
                                    .font(.headline)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                        }
                        
                        if memories.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.6))
                                
                                Text("No photo yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.08))
                            )
                            
                        } else {
                            ScrollView(.horizontal) {
                                HStack(spacing: 12) {
                                    ForEach(memories) { memory in
                                        if let uiImage = UIImage(data: memory.imageData) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 150)
                                                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                                                .padding(.bottom, 12)
                                                .padding(.top, 4)
                                                .onTapGesture {
                                                    selectedMemory = memory
                                                }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .scrollTargetBehavior(.viewAligned)
                            .scrollIndicators(.hidden)
                            .padding(.horizontal, -20)
                        }
                    }
                    .padding(.bottom, 12)
                    
                    
                    VStack(alignment: .leading) {
                        NavigationLink {
                            CollectionDetailView(name: "All Albums", albums: albums)
                        } label: {
                            HStack{
                                Text("All Albums").font(.headline)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                        }
                        if albums.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "rectangle.stack")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.6))
                                
                                Text("No album yet")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 150)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.gray.opacity(0.08))
                            )
                        } else {
                            ScrollView(.horizontal) {
                                HStack(spacing: 12) {
                                    ForEach(albums) { album in
                                        AlbumCard(
                                            album: album
                                        )
                                        .frame(width: 140)
                                        .scrollTargetLayout()
                                        .contextMenu {
                                            Button {
                                                selectedAlbum = album
                                                showEditSheet = true
                                            } label: {
                                                Label("Edit Album", systemImage: "pencil")
                                            }
                                            
                                            Button(role: .destructive) {
                                                deletedAlbum = album
                                                showDeleteConfirm = true
                                            } label: {
                                                Label("Delete Album", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .scrollTargetBehavior(.viewAligned)
                            .scrollIndicators(.hidden)
                            .padding(.horizontal, -20)
                            .confirmationDialog("Delete this album?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                                Button("Delete", role: .destructive) {
                                    if let album = deletedAlbum {
                                        deleteAlbum(album)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 12)
                        
                    
                    ForEach(collections) { collection in
                        VStack(alignment: .leading) {
                            NavigationLink {
                                CollectionDetailView(
                                    name: collection.name, collection: collection,
                                    albums: collection.albums
                                )
                            } label: {
                                HStack{
                                    Text(collection.name).font(.headline)
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.primary)
                            }
                            if collection.albums.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "rectangle.stack.badge.plus")
                                        .font(.system(size: 32))
                                        .foregroundColor(.gray.opacity(0.6))
                                    
                                    Text("Empty collection")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text("Open this collection to add albums.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 120)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.08))
                                )
                            } else {
                                ScrollView(.horizontal) {
                                    HStack(spacing: 12) {
                                        ForEach(collection.albums) { album in
                                            AlbumCard(
                                                album: album
                                            )
                                            .frame(width: 140)
                                            .scrollTargetLayout()
                                            .contextMenu {
                                                Button {
                                                    selectedAlbum = album
                                                    showEditSheet = true
                                                } label: {
                                                    Label("Edit Album", systemImage: "pencil")
                                                }
                                                
                                                Button(role: .destructive) {
                                                    deletedAlbum = album
                                                    showDeleteConfirm = true
                                                } label: {
                                                    Label("Delete Album", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                                .scrollTargetBehavior(.viewAligned)
                                .scrollIndicators(.hidden)
                                .padding(.horizontal, -20)
                            }
                        }
                        .padding(.bottom, 12)
                    }
                }
                .padding(.horizontal, 20)
                .navigationTitle("Collection")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                showAddCollectionSheet = true
                            } label: {
                                Label("New Collection", systemImage: "rectangle.stack.badge.plus")
                            }
                            
                            Button {showAddBookSheet = true
                                
                            } label: {
                                Label("New Album", systemImage: "book.badge.plus")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAddCollectionSheet) {
                    AddCollectionSheet()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $showAddBookSheet) {
                    AddAlbumSheet()
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
                .sheet(item: $selectedAlbum) { album in
                    AddAlbumSheet(existingAlbum: album, mode: .edit)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
                .sheet(item: $selectedMemory) { memory in
                    DetailSheet(memory: memory) {
                        selectedMemory = nil
                    }
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
    
    func deleteAlbum(_ album: Album) {
        withAnimation {
            context.delete(album)
        }
        deletedAlbum = nil
    }
}

#Preview {
    CollectionView()
}
