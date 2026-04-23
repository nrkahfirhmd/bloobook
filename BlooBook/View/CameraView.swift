//
//  CameraView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 16/04/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct CameraView: View {
    @ObservedObject var camera: CameraManager
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var currentImage: UIImage?
    @State private var showSavePopup: Bool = false
    @State private var showFrameSelection: Bool = false
    @State private var titleText = ""
    @State private var noteText = ""
    @State private var savedImage: UIImage?
    
    let frames = ["stamp_frame_1", "stamp_frame_2", "stamp_frame_3", "polaroid_frame_1", "polaroid_frame_2", "polaroid_frame_3"]
    let stamps = ["stamp_1", "stamp_2", "stamp_3", "polaroid_frame_1", "polaroid_frame_2", "polaroid_frame_3"]
    @State private var selectedFrameIndex: Int = 0
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            ZStack {
                CameraPreview(session: camera.session)
                    .ignoresSafeArea()
                
                StampOverlay(selectedFrame: frames[selectedFrameIndex])
                
                VStack {
                    HStack {
                        Spacer()

                        Button(action: {camera.switchCamera()}) {
                            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    if showFrameSelection {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 40) {
                                ForEach(frames, id: \.self) { frame in
                                    HStack {
                                        Image(frame)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50)
                                            .onTapGesture {
                                                selectedFrameIndex = frames.firstIndex(of: frame) ?? 0
                                            }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                        }
                    }
                    
                    HStack {
                        Button(action: {showFrameSelection.toggle()}) {
                            Image(systemName: "circle.rectangle.dashed")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            
                            camera.capturePhoto()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 100, height: 100)
                            }
                            .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        .onReceive(camera.$capturedImage) { image in
                            if let image = image {
                                currentImage = image
                                
                                showSavePopup = true
                            }
                        }
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Image(systemName: "photo.on.rectangle.angled.fill")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        .onChange(of: selectedItem) { oldValue, newValue in
                            guard let newItem = newValue else { return }
                            
                            Task {
                                if let data = try? await newItem.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    await MainActor.run {
                                        currentImage = image
                                        
                                        selectedItem = nil
                                    }
                                }                             }
                        }
                        .onChange(of: currentImage) {_, newImage in
                            if newImage != nil {
                                showSavePopup = true
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(Color.black.opacity(0.8).edgesIgnoringSafeArea(.all))
            .onAppear {
                camera.setup()
            }
            .onDisappear {
                camera.stopSession()
            }
        }
        .sheet(isPresented: $showSavePopup) {
            if let currentImage = currentImage {
                let selectedStampBinding: Binding<String> = Binding(
                    get: { stamps[selectedFrameIndex] },
                    set: { newValue in
                        if let newIndex = stamps.firstIndex(of: newValue) {
                            selectedFrameIndex = newIndex
                        }
                    }
                )
                SavePopupSheet(
                    currentImage: currentImage,
                    stamp: selectedStampBinding,
                    showSavePopup: $showSavePopup,
                    album: nil
                )
                .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    let cameraManager = CameraManager()
    return CameraView(camera: cameraManager)
}
