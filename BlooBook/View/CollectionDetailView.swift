//
//  DetailedCollectionView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI

struct CollectionDetailView: View {
    var collection: String
    var albums: [Album]
    
    @State private var columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24){
                    ForEach(albums) { album in
                        BookCard(
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
        }
    }
}

#Preview {
//    CollectionDetailView(collection: "Book", albums: AlbumModel.sampleData)
}
