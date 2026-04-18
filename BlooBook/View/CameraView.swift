//
//  CameraView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 16/04/26.
//

import SwiftUI
import PhotosUI

struct CameraView: View {
    @StateObject var camera = CameraManager()
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var currentImage: UIImage?
    @State private var showSavePopup: Bool = false
    @State private var showFrameSelection: Bool = false
    @State private var titleText = ""
    @State private var noteText = ""
    @State private var savedImage: UIImage?
    @State private var memories: [Memory] = []
    
    let frames = ["stamp_frame_1", "stamp_frame_2", "stamp_frame_3"]
    let stamps = ["stamp_1", "stamp_2", "stamp_3"]
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
                        
                        NavigationLink {
                            ShowcaseView(memories: memories)
                        } label: {
                            Image(systemName: "house")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
                        
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
                                    }
                                }
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
        }
        .sheet(isPresented: $showSavePopup) {
            VStack(spacing: 20) {
                Text("Save Memory")
                    .font(.title2)
                    .bold()
                
                if let image = currentImage {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded{ _ in lastOffset = offset }
                            )
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { _ in lastScale = scale }
                            )
                    }
                    .frame(width: 250, height: 250)
                    .clipped()
                    .mask {
                        Image(stamps[selectedFrameIndex])
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(0.55)
                    }
                }
                
                TextField("Title", text: $titleText)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Note", text: $noteText)
                    .textFieldStyle(.roundedBorder)
                
                Button("Save") {
                    if let image = currentImage {
                        if let mask = UIImage(named: stamps[selectedFrameIndex]) {
                            let final = renderFinalImage(
                                photo: image,
                                maskImage: mask,
                                scale: scale,
                                offset: offset,
                                canvasSize: CGSize(width: 500, height: 500)
                            )
                            savedImage = final
                            let memory = Memory(image: final, title: titleText, note: noteText, date: Date())
                            
                             memories.append(memory)
                        }
                    }

                    showSavePopup = false
                }
                
                Button("Cancel") {
                    showSavePopup = false
                }
            }
            .padding()
            .presentationDragIndicator(.visible)
        }
    }
    
    func renderFinalImage(
        photo: UIImage,
        maskImage: UIImage,
        scale: CGFloat,
        offset: CGSize,
        canvasSize: CGSize
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        
        var maskRect: CGRect = .zero
        
        let image = renderer.image { context in
            let cg = context.cgContext
                    
            let maskAspect = maskImage.size.width / maskImage.size.height
            let canvasAspect = canvasSize.width / canvasSize.height
            
            var maskWidth: CGFloat
            var maskHeight: CGFloat
            
            if maskAspect > canvasAspect {
                maskWidth = canvasSize.width
                maskHeight = canvasSize.width / maskAspect
            } else {
                maskHeight = canvasSize.height
                maskWidth = canvasSize.height * maskAspect
            }
            
            let scaleEffect: CGFloat = 0.55
            maskWidth *= scaleEffect
            maskHeight *= scaleEffect
            
            let maskOrigin = CGPoint(
                x: (canvasSize.width - maskWidth) / 2,
                y: (canvasSize.height - maskHeight) / 2
            )
            
            maskRect = CGRect(origin: maskOrigin, size: CGSize(width: maskWidth, height: maskHeight))
            
            if let maskCG = maskImage.cgImage {
                cg.saveGState()
                cg.clip(to: maskRect, mask: maskCG)
            }
            
            cg.translateBy(
                x: canvasSize.width / 2 + offset.width,
                y: canvasSize.height / 2 + offset.height
            )
            
            cg.scaleBy(x: scale, y: scale)
            
            let aspectWidth = canvasSize.width / photo.size.width
            let aspectHeight = canvasSize.height / photo.size.height
            let fillScale = max(aspectWidth, aspectHeight)
            
            let drawWidth = photo.size.width * fillScale
            let drawHeight = photo.size.height * fillScale
            
            let drawRect = CGRect(
                x: -drawWidth / 2,
                y: -drawHeight / 2,
                width: drawWidth,
                height: drawHeight
            )
            
            photo.draw(in: drawRect)
            
            cg.restoreGState()
        }
        
        let scaleFactor = image.scale
        
        let scaledRect = CGRect(
            x: maskRect.origin.x * scaleFactor,
            y: maskRect.origin.y * scaleFactor,
            width: maskRect.size.width * scaleFactor,
            height: maskRect.size.height * scaleFactor
        )
        
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else {
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: scaleFactor, orientation: image.imageOrientation)
    }
}

#Preview {
    CameraView()
}
