//
//  CollectionView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI

struct CollectionView: View {
    @State private var stamps: [StampModel] = [
        StampModel(
            position: CGPoint(x: 200, y: 300),
            source: .photo1,
            stamp: .stampVertical
        ),
        StampModel(
            position: CGPoint(x: 200, y: 300),
            source: .photo2,
            stamp: .stampVertical
        ),
        StampModel(
            position: CGPoint(x: 200, y: 300),
            source: .photo3,
            stamp: .stampVertical
        ),
        StampModel(
            position: CGPoint(x: 200, y: 300),
            source: .photo4,
            stamp: .stampVertical
        ),
        StampModel(
            position: CGPoint(x: 200, y: 300),
            source: .photo5,
            stamp: .stampVertical
        )
    ]
    @State private var albums: [AlbumModel] = [
        AlbumModel(color: .blue, image: .photo1, name: "Batur", date: Date.now),
        AlbumModel(color: .red, image: .photo2, name: "Me & Batur", date: Date.now),
        AlbumModel(color: .gray, image: .photo3, name: "Challenge 1", date: Date.now),
        AlbumModel(color: .cyan, image: .photo4, name: "Cohort '26", date: Date.now),
        AlbumModel(color: .brown, image: .photo5, name: "Plenger", date: Date.now),
    ]
    @State private var collections = ["Traveling", "Food", "Friends", "Fams"]
    var body: some View {
        NavigationStack{
            ScrollView {
                VStack{
                    VStack(alignment: .leading) {
                        NavigationLink {
                            CollectionDetailView()
                        } label: {
                            HStack{
                                Text("All Stamps").font(.headline)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                        }
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach($stamps) { $stamp in
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
                    
                    ForEach(collections, id: \.self) { collection in
                        VStack(alignment: .leading) {
                            NavigationLink {
                                CollectionDetailView()
                            } label: {
                                HStack{
                                    Text(collection).font(.headline)
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.primary)
                            }
                            ScrollView(.horizontal) {
                                HStack(spacing: 12) {
                                    ForEach($albums) { $album in
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
                .toolbar{
                    ToolbarItem{
                        Button("Add", systemImage: "plus"){
                            
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CollectionView()
}
