//
//  BackgroundPicker.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 17/04/26.
//

import SwiftUI

struct BackgroundPicker: View {
    
    var onSelect: (ImageResource) -> Void
    
    let backgrounds: [ImageResource] = [
        .paper1, .paper2
    ]
    
    var body: some View {
        
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(backgrounds, id: \.self) { bg in
                    Image(bg)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 50)
                        .clipped()
                        .cornerRadius(12)
                        .onTapGesture {
                            onSelect(bg)
                        }
                }
            }
            .padding()
        }
    
}
