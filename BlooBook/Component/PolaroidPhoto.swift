//
//  PolaroidPhoto.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 23/04/26.
//

import SwiftUI

struct PolaroidPhoto: View {
    var image: UIImage
    var ratio: CGFloat = 1
    
    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .aspectRatio(ratio, contentMode: .fit)
                .clipped()
            
            Color.white
                .frame(height: 40)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(6)
        .shadow(radius: 5)
    }
}

#Preview {
    PolaroidPhoto(image: .photo2, ratio: 9/16)
}
