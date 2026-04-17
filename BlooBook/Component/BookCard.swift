//
//  BookCard.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI

struct BookCard: View {
    var body: some View {
        NavigationLink {
            BookDetailView()
        } label: {
            VStack(alignment: .leading) {
                ZStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.cyan)
                        Image(.book)
                            .resizable()
                            .scaledToFit()
                            .blendMode(.multiply)
                    }
                    .frame(width: 144, height: 210)
                    .clipped()
                    
                    Image(.batur)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 120)
                        .clipped()
                        .mask(
                            Image(.stampVertical)
                                .resizable()
                                .scaledToFit()
                        )
                        .rotationEffect(.degrees(-12))
                        .offset(x: 20, y: -54)
                    
                    //                Image(.batur)
                    //                    .resizable()
                    //                    .scaledToFit()
                    //                    .frame(height: 40)
                    //                    .clipped()
                    //                    .mask(
                    //                        Image(.stampVertical)
                    //                            .resizable()
                    //                            .scaledToFit()
                    //                    )
                    //                    .rotationEffect(.degrees(26))
                    //                    .offset(x: -24, y: -44)
                    
                    //                Image(.batur)
                    //                    .resizable()
                    //                    .scaledToFit()
                    //                    .frame(height: 24)
                    //                    .clipped()
                    //                    .mask(
                    //                        Image(.stampVertical)
                    //                            .resizable()
                    //                            .scaledToFit()
                    //                    )
                    //                    .rotationEffect(.degrees(-17))
                    //                    .offset(x: 20, y: -50)
                    
                    VStack(alignment: .trailing){
                        Text("Bali")
                            .font(.headline)
                        Text("Apr 2026")
                            .font(.caption)
                    }
                    .foregroundColor(.black)
                    .offset(x: 30, y: 70)
                    
                    
                    
                }
                .cornerRadius(2)
                .clipped()
                //
                //            Text("Title")
                //                .font(.headline)
                //            Text("16 Apr 2026")
                //                .font(.caption)
            }
        }
    }
    
}


#Preview {
    BookCard()
}
