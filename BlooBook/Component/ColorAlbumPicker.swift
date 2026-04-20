//
//  ColorPicker.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 20/04/26.
//

import SwiftUI

struct ColorAlbumPicker: View {
    @Binding var selectedColor: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Color")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(presetColors, id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 32, height: 32)
                            .overlay {
                                if selectedColor == color {
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                        .padding(2)
                                }
                            }
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
//
//#Preview {
//    ColorAlbumPicker(selectedColor: )
//}
