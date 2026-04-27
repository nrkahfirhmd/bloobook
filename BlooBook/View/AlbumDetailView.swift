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
    
    @State private var draggingPhotoID: UUID? = nil
    @State private var draggingStickerID: UUID? = nil
    @State private var draggingTextID: UUID? = nil
    
    @State private var isDragging = false
    @State private var isOverTrash = false
    @State private var showBackgroundPicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var currentImage: UIImage?
    @State private var showSavePopup: Bool = false
    @State private var defaultStamp: String = "stamp_1"
    @State private var trashFrame: CGRect = .zero
    @State private var editingText: CanvasText?
    
    @State private var showMemoryPicker: Bool = false
    @State private var showStickerPicker: Bool = false
    @State private var showTextEditor: Bool = false
    
    @Query var memories : [Memory]
    @Query var photos: [Photo]
    @Query var stickers: [Sticker]
    @Query var texts: [CanvasText]
    
    let screenSize = UIScreen.main.bounds.size
    
    init(album: Album) {
        self.album = album
    }
    
    var album: Album
    
    var body: some View {
        ZStack {
            Image(backgroundImage(from: album.backgroundName))
                .resizable()
                .scaledToFill()
                .frame(width: screenSize.width, height: screenSize.height)
                .ignoresSafeArea()
            
            trashLayer
            
            photosLayer
            stickersLayer
            textLayer
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
        .onAppear() {
            editingText = CanvasText(text: TextContent(content: ""), position: CGPoint(x: 300, y: 250), scale: 1, rotation: Angle(degrees: 0), albums: [album])
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
                        album.backgroundName = "paper1"
                    } label: {
                        Text("White")
                    }
                    
                    Button {
                        album.backgroundName = "paper2"
                    } label: {
                        Text("Vintage")
                    }
                    
                    Button {
                        album.backgroundName = "paper3"
                    } label: {
                        Text("Dark")
                    }
                } label: {
                    Image(systemName: "paintpalette.fill")
                }
                
                Spacer()
                
                Menu {
                    Button {
                        showMemoryPicker.toggle()
                    } label: {
                        Label("Memories", systemImage: "photo.artframe")
                    }
                    
                    Button {
                        showStickerPicker.toggle()
                    } label: {
                        Label("Stickers", systemImage: "puzzlepiece.extension.fill")
                    }
                    
                    Button {
                        showTextEditor.toggle()
                    } label: {
                        Label("Text", systemImage: "textformat")
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        if let image = await RenderAlbum() {
                            shareImage(image)
                        }
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbarColorScheme(
            album.backgroundName == "paper3" ? .dark : .light,
            for: .navigationBar
        )
        .tint(album.backgroundName == "paper3" ? .white : .black)
        .navigationTitle(album.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showSavePopup) {
            SavePopupSheet(currentImage: currentImage, stamp: $defaultStamp, showSavePopup: $showSavePopup, album: album)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showMemoryPicker) {
            PhotoPickerSheet(memories: memories, album: album)
                .padding()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showStickerPicker) {
            StickerPickerSheet(album: album)
                .padding()
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showTextEditor) {
            if let text = editingText {
                TextEditorSheet(album: album, textItem: text)
                    .padding()
                    .presentationDragIndicator(.visible)
            }
        }
        
        
    }
    @MainActor
    func RenderAlbum() -> UIImage? {
        
        let view = albumContentView
            .frame(width: screenSize.width, height: screenSize.height)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        
        return renderer.uiImage
    }
    var albumContentView: some View {
        GeometryReader { proxy in
            ZStack {
                Image(backgroundImage(from: album.backgroundName))
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenSize.width, height: screenSize.height)
                    .ignoresSafeArea()
                
                photosLayer
                stickersLayer
                textLayer
            }
        }
        .coordinateSpace(name: "canvas")
        
    }
    
    func shareImage(_ image: UIImage) {
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(activityVC, animated: true)
        }
    }
    
    func saveToPhotos(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func backgroundImage(from name: String) -> ImageResource {
        switch name {
        case "paper1": return .paper1
        case "paper2": return .paper2
        case "paper3": return .paper3
        default: return .paper1
        }
    }
    
    @ViewBuilder
    var trashLayer: some View {
        VStack {
            Spacer()
            
            if isDragging {
                VStack{
                    Text("Drag to delete")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(album.backgroundName == "paper3" ? .white : .black)
                    Image(systemName: "trash.circle.fill")
                        .font(.system(size: 60))
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear {
                                        trashFrame = geo.frame(in: .global)
                                    }
                                    .onChange(of: geo.frame(in: .global)) { newValue in
                                        trashFrame = newValue
                                    }
                            }
                        )
                    
                }
                .padding(.bottom, 100)
                .foregroundColor(isOverTrash ? .red : .gray)
                .scaleEffect(isOverTrash ? 1.2 : 1)
                .animation(.easeInOut, value: isOverTrash)
            }
        }
    }
    
    @ViewBuilder
    var photosLayer: some View {
        ForEach(album.photos) { photo in
            DraggablePhoto(
                photo: photo,
                draggingPhotoID: $draggingPhotoID,
                isDragging: $isDragging,
                isOverTrash: $isOverTrash,
                trashFrame: $trashFrame,
            )
        }
    }
    
    @ViewBuilder
    var stickersLayer: some View {
        ForEach(album.stickers) { sticker in
            DraggableSticker(
                sticker: sticker,
                draggingStickerID: $draggingStickerID,
                isDragging: $isDragging,
                isOverTrash: $isOverTrash,
                trashFrame: $trashFrame
            )
            .allowsHitTesting(!(isDragging && draggingStickerID == sticker.id))
            .zIndex(draggingStickerID == sticker.id ? 100 : 0)
        }
    }
    
    @ViewBuilder
    var textLayer: some View {
        ForEach(album.texts) { text in
            DraggableText(
                textItem: text,
                draggingTextID: $draggingTextID,
                isDragging: $isDragging,
                isOverTrash: $isOverTrash,
                trashFrame: $trashFrame,
                backgroundImage: backgroundImage(from: album.backgroundName)
            )
        }
    }
}
