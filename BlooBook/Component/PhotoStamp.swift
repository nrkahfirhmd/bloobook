//
//  PhotoStamp.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 17/04/26.
//

import SwiftUI

struct PhotoStamp: View {
    
    let photo: StampModel
    
    var body: some View {
        Group {
            if let uiImage = photo.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    
            } else if let source = photo.source {
                Image(source)
                    .resizable()
                    .scaledToFill()
                    
            }
        }
        .frame(height: 160)
        .mask(
            Image(photo.stamp)
                .resizable()
                .scaledToFit()
                .frame(height: 160)
        )
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let newStamp = StampModel(
        position: CGPoint(x: 200, y: 300),
        source: .photo1,
        stamp: .stampVertical
    )
    PhotoStamp(photo: newStamp)
}


