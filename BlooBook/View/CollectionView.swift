//
//  CollectionView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI

struct CollectionView: View {
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
                                ForEach(0..<10) { _ in
                                    PhotoStamp(
                                        photo: StampModel(
                                            position: CGPoint(x: 200, y: 300),
                                            source: .batur,
                                            stamp: .stampVertical
                                        )
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
                    
                    
                    VStack(alignment: .leading) {
                        NavigationLink {
                            CollectionDetailView()
                        } label: {
                            HStack{
                                Text("Traveling").font(.headline)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                        }
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(0..<10) { _ in
                                    BookCard()
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
                    
                    VStack(alignment: .leading) {
                        NavigationLink {
                            CollectionDetailView()
                        } label: {
                            HStack{
                                Text("Foods").font(.headline)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.primary)
                        }
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(0..<10) { _ in
                                    BookCard()
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
                    .padding(.bottom,12)
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
