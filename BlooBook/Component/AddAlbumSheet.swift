//
//  AddBookSheet.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 18/04/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct AddAlbumSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @State private var name = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var selectedColor: Color = .blue
    
    var existingAlbum: Album? = nil
    var mode: SaveMode = .create
    
    var body: some View {
        NavigationStack {
            
            Form {
                Section {
                    VStack(alignment: .center) {
                        ZStack {
                            if let imageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo")
                                        .font(.system(size: 32))
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 250, height: 250)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.1))
                        )
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Text("Add Photos")
                                .font(.headline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(.regularMaterial)
                                .clipShape(Capsule())
                        }
                    }
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity)
                }
                
                Section {
                    TextField("Album Name", text: $name)
                        .bold()
                }
                
                Section {
                    ColorAlbumPicker(selectedColor: $selectedColor)
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
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
                        mode == .create ? saveAlbum() : updateAlbum()

                        dismiss()
                    } label: {
                        Text(mode == .create ? "Create" : "Edit")
                    }
                    .buttonStyle(.glassProminent)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("New Book")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear() {
                loadExistingAlbum()
            }
            .onChange(of: existingAlbum) { _, _ in
                loadExistingAlbum()
            }
        }
    }
    
    func loadExistingAlbum() {
        guard mode == .edit, let album = existingAlbum else { return }
            
        name = album.name
        imageData = album.imageData
        selectedColor = album.color
    }
    
    func saveAlbum() {
        let album = Album(colorData: selectedColor.toData()!, imageData: imageData!, name: name, date: Date.now, photos: [], stickers: [], texts: [])
        context.insert(album)
    }
    
    func updateAlbum() {
        guard let album = existingAlbum else { return }
        
        album.name = name
        if let image = imageData {
            album.imageData = image
        }
        album.colorData = selectedColor.toData()!
        
        dismiss()
    }
}

#Preview {
    AddAlbumSheet()
}

