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
    
    @Query var collections: [Collection]
    @Query var memories: [Memory]
    @Query var albums: [Album]
    @Query var photos: [Photo]
    
    @State private var showAddCollectionSheet = false
    @State private var showAddBookSheet = false
    @State private var showEditSheet = false
    @State private var showDeleteConfirm = false
    @State private var selectedAlbum: Album?
    
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack{
                    VStack(alignment: .leading) {
                        NavigationLink {
                            ShowcaseView()
                        } label: {
                            HStack{
                                Text("All Stamps").font(.headline)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                        }
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(memories) { memory in
                                    if let uiImage = UIImage(data: memory.imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 150)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .scrollIndicators(.hidden)
                        .padding(.horizontal, -20)
                    }
                    .padding(.bottom, 12)
                    
                    
                    VStack(alignment: .leading) {
                        NavigationLink {
                            CollectionDetailView(collection: "All Albums", albums: albums)
                        } label: {
                            HStack{
                                Text("All Albums").font(.headline)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                        }
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
                                            showEditSheet = true
                                        } label: {
                                            Label("Edit Album", systemImage: "pencil")
                                        }
                                        
                                        Button(role: .destructive) {
                                            selectedAlbum = album
                                            showDeleteConfirm = true
                                        } label: {
                                            Label("Delete Album", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .confirmationDialog("Delete this album?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                            Button("Delete", role: .destructive) {
                                if let album = selectedAlbum {
                                    deleteAlbum(album)
                                }
                            }
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .scrollIndicators(.hidden)
                        .padding(.horizontal, -20)
                    }
                    .padding(.bottom, 12)
                    
                    ForEach(collections) { collection in
                        VStack(alignment: .leading) {
                            NavigationLink {
                                CollectionDetailView(
                                    collection: collection.name,
                                    albums: collection.albums
                                )
                            } label: {
                                HStack{
                                    Text(collection.name).font(.headline)
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.primary)
                            }
                            ScrollView(.horizontal) {
                                HStack(spacing: 12) {
                                    ForEach(collection.albums) { album in
                                        AlbumCard(
                                            album: album
                                        )
                                        .frame(width: 140)
                                        .scrollTargetLayout()
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .scrollTargetBehavior(.viewAligned)
                            .scrollIndicators(.hidden)
                            .padding(.horizontal, -20)
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
                }
                .sheet(isPresented: $showAddBookSheet) {
                    AddAlbumSheet()
                        .presentationDetents([.large])
                }
                .sheet(isPresented: $showEditSheet) {
                    AddCollectionSheet()
                        .presentationDetents([.large])
                }
            }
        }
    }
    
    func deleteAlbum(_ album: Album) {
        withAnimation {
            context.delete(album)
        }
        selectedAlbum = nil
    }
}

#Preview {
    CollectionView()
}
