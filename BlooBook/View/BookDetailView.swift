//
//  BookDetailView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI
import PhotosUI

struct BookDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showBackgroundPicker = false
    @State private var background: ImageResource = .paper1
    @State private var selectedItem: PhotosPickerItem?
    @State private var stamps: [StampModel] = []
    var album: AlbumModel
    var body: some View {
        ZStack {
            Image(background)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if stamps.isEmpty {
                Text("Tap + to add stamp")
                    .foregroundStyle(.gray)
            }
            
            ForEach($stamps) { $stamp in
                DraggableStamp(stamp: $stamp)
            }
        }
        .onChange(of: selectedItem) {
            
            Task {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    
                    addStamp(image: uiImage)
                    selectedItem = nil
                }
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
            
            ToolbarItem(placement: .bottomBar){
                
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
    }
    
    func addStamp(image: UIImage) {
        let newStamp = StampModel(
            position: CGPoint(x: 200, y: 350),
            image: image,
            source: nil,
            stamp: .stampVertical
        )
        
        withAnimation(.spring()) {
            stamps.append(newStamp)
        }
    }
    
}

