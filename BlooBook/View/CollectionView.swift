//
//  CollectionView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI

struct CollectionView: View {
    @State private var collections = []
    @State private var showAddCollectionSheet = false
    @State private var showAddBookSheet = false
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack{
                    VStack(alignment: .leading) {
                        NavigationLink {
                            CollectionDetailView(collection: "All Stamps", albums: AlbumModel.sampleData)
                        } label: {
                            HStack{
                                Text("All Stamps").font(.headline)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                        }
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(StampModel.sampleData) { stamp in
                                    PhotoStamp(
                                        photo: stamp
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
                    
                    ForEach(CollectionModel.sampleData) { collection in
                        VStack(alignment: .leading) {
                            NavigationLink {
                                CollectionDetailView(
                                    collection: collection.name,
                                    albums: collection.album
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
                                    ForEach(AlbumModel.sampleData) { album in
                                        BookCard(
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
                                Label("New Book", systemImage: "book.badge.plus")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showAddCollectionSheet) {
                    AddCollectionSheet()
                        .presentationDetents([.medium])
                        .presentationBackground(.white)
                }
                .sheet(isPresented: $showAddBookSheet) {
                    AddBookSheet()
                        .presentationDetents([.large])
                        .presentationBackground(.white)
                }
            }
        }
    }
}

#Preview {
    CollectionView()
}
