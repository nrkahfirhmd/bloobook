//
//  AddBookSheet.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 18/04/26.
//

import SwiftUI
import PhotosUI

struct AddBookSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var word = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    var body: some View {
        NavigationStack {
            
            VStack {
                
                if let imageData,
                   let uiImage = UIImage(data: imageData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 100)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .frame(width: 250, height: 250)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .foregroundColor(.secondary)
                }
                
            
                Button("Add Photo"){}
                    .font(.headline)
                    
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.regularMaterial)
                    .clipShape(Capsule())
                
                Form {
                    Section {
                        
                        TextField("Album Name", text: $word)
                            .bold()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            saveBook()
                            dismiss()
                        } label: {
                            Text("Create")
                            
                        }
                        .buttonStyle(.glassProminent)
                    }
                    ToolbarItem {
                        
                        
                    }
                }
                .navigationTitle("New Collection")
                .navigationBarTitleDisplayMode(.inline)
            }
            .background(.thickMaterial)
        }
        
    }
    
    func saveBook() {
        
        
    }
}

#Preview {
    AddBookSheet()
}
