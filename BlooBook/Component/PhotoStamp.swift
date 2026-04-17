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
        ZStack {
            Image(photo.source)
                .resizable()
                .scaledToFit()
                .frame(height: 160)
                .mask(
                    Image(photo.stamp)
                        .resizable()
                        .scaledToFit()
                )
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)   
        }
    }
}

#Preview {
    let newStamp = StampModel(
        position: CGPoint(x: 200, y: 300),
        source: .batur,
        stamp: .stampVertical
    )
    PhotoStamp(photo: newStamp)
}


