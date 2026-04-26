//
//  StickerPickerSheet.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 24/04/26.
//

import SwiftUI
import SwiftData

struct StickerPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    
    @State private var selectedStickers: Set<URL> = []
    @Bindable var album: Album
    @State private var stickerURLs: [URL] = []
    
    var columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    if stickerURLs.isEmpty {
                        Text("Kosong pak kaya hati")
                    } else {
                        ForEach(stickerURLs, id: \.self) { url in
                            selectableCard(url)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Add Sticker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction){
                    Button(role: .confirm){
                        saveSticker()
                         dismiss()
                    }label: {
                       Image(systemName: "checkmark")
                    }
                }
                ToolbarItem(placement: .cancellationAction){
                    Button(role: .cancel){
                         dismiss()
                    }label: {
                       Image(systemName: "xmark")
                    }
                }
            }
        }
        .onAppear {
            if let urls = Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: "Stickers") {
                stickerURLs = urls
            }
        }
    }
    
    func selectableCard(_ url: URL) -> some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(contentsOfFile: url.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .opacity(selectedStickers.contains(url) ? 0.7 : 1)
            }
            
            if selectedStickers.contains(url) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .background {
                        Circle()
                            .fill(.primary)
                    }
                    .overlay {
                        Circle()
                            .stroke(Color.primary, lineWidth: 2)
                    }
                    .padding(12)
            }
        }
        .onTapGesture {
            toggle(url)
        }
    }
    
    func toggle(_ url: URL){
        if selectedStickers.contains(url) {
            selectedStickers.remove(url)
        } else {
            selectedStickers.insert(url)
        }
    }
    
    func saveSticker() {
        for url in selectedStickers {
            let alreadyExists = album.stickers.contains {
                $0.url == url
            }
            
            if !alreadyExists,
               let image = UIImage(contentsOfFile: url.path)
            {
                let sticker = Sticker(
                    image: image,
                    position: CGPoint(
                        x: CGFloat.random(in: 100...300),
                        y: CGFloat.random(in: 200...500)
                    ),
                    scale: 1,
                    rotation: Angle(degrees: 0),
                    albums: [album],
                    url: url
                )
                
                context.insert(sticker)
                album.stickers.append(sticker)
            }
        }
        
        selectedStickers.removeAll()
    }
}
