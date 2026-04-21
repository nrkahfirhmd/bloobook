//
//  BookDetailView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct AlbumDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var showBackgroundPicker = false
    @State private var background: ImageResource = .paper1
    @State private var selectedItem: PhotosPickerItem?
    @State private var currentImage: UIImage?
    @State private var showSavePopup: Bool = false
    @State private var defaultStamp: String = "stamp_1"
    
    @Query var photos: [Photo]
    
    init(album: Album) {
        self.album = album
        _photos = Query()
    }
    
    var filteredPhotos: [Photo] {
        photos.filter { $0.albums.contains(album) }
    }
    
    var album: Album
    
    var body: some View {
        ZStack {
            Image(background)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if photos.isEmpty {
                Text("Tap + to add stamp")
                    .foregroundStyle(.gray)
            }
            
            ForEach(photos) { photo in
                DraggableStamp(photo: photo)
            }
        }
        .onChange(of: selectedItem) {
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    currentImage = uiImage
                    
                    selectedItem = nil
                } else {
                    await MainActor.run {
                        selectedItem = nil
                    }
                }
            }
        }
        .onChange(of: currentImage) { _, newImage in
            if newImage != nil {
                showSavePopup = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "photo")
                }
                
                Menu {
                    Button {
                        background = .paper1
                    } label: {
                        HStack {
                            Image(.paper1)
                                .resizable()
                                .frame(width: 30, height: 40)
                            Text("White")
                        }
                    }
                    Button {
                        background = .paper2
                    } label: {
                        HStack {
                            Image(.paper2)
                                .resizable()
                                .frame(width: 30, height: 40)
                            Text("Vintage")
                        }
                    }
                    
                } label: {
                    Image(systemName: "paintpalette.fill")
                }
                
                Spacer()
                
                
                
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                }
                
                
                
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showSavePopup) {
            SavePopupSheet(currentImage: currentImage, stamp: $defaultStamp, showSavePopup: $showSavePopup, album: album)
                .presentationDragIndicator(.visible)
        }
    }
    
//    func addPhoto(image: UIImage) {
//        let newMemory = Memory(image: UIImage, title: String, note: <#T##String#>, date: <#T##Date#>)
//        
//        let newPhoto = Photo(position: CGPoint(x: 200, y: 350), memory: <#T##Memory#>, album: <#T##[Album]#>)
//        
//        let newStamp = StampModel(
//            position: CGPoint(x: 200, y: 350),
//            image: image,
//            source: nil,
//            stamp: .stampVertical
//        )
//        
//        withAnimation(.spring()) {
//            stamps.append(newStamp)
//        }
//    }
    
}

