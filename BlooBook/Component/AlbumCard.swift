//
//  BookCard.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI

struct AlbumCard: View {
    let album: Album
    var isSelectable: Bool = false
    
    var body: some View {
        Group {
            if isSelectable {
                content
            } else {
                NavigationLink {
                    AlbumDetailView(album: album)
                } label: {
                    content
                }
            }
        }
    }
    
    var content: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Rectangle()
                        .foregroundColor(album.color)
                    Image(.book)
                        .resizable()
                        .scaledToFit()
                        .blendMode(.multiply)
                }
                .frame(width: 144, height: 210)
                
                if let uiImage = UIImage(data: album.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 120)
                        .mask(
                            Image(.stampVertical)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 120)
                        )
                        .rotationEffect(.degrees(-12))
                        .position(x: 100, y: 45)
                }
                
                VStack(alignment: .trailing){
                    Text(album.name)
                        .font(.headline)
                    Text(album.date, format: .dateTime.month().year())
                        .font(.caption)
                }
                .padding()
                .foregroundColor(.black)
            }
            .cornerRadius(6)
        }
    }
}
