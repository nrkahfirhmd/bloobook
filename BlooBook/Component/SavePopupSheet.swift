//
//  SavePopupView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 17/04/26.
//

import SwiftUI

struct SavePopupSheet: View {
    var currentImage: UIImage?
    @State private var titleText = ""
    @State private var noteText = ""
    @State private var savedImage: UIImage?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Save Memory")
                .font(.title2)
                .bold()
            
            TextField("Title", text: $titleText)
                .textFieldStyle(.roundedBorder)
            
            TextField("Note", text: $noteText)
                .textFieldStyle(.roundedBorder)
            
            Button("Save") {
                if let image = currentImage {
                    savedImage = image
                    
                    print("Saved", titleText, noteText)
                }
            }
        }
    }
}

#Preview {
    SavePopupSheet()
}
