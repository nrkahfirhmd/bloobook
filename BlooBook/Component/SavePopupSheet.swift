//
//  SavePopupView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 17/04/26.
//

import SwiftUI
import SwiftData

enum SaveMode {
    case create
    case edit
}

struct SavePopupSheet: View {
    @Environment(\.modelContext) private var context
    
    var currentImage: UIImage?
    @Binding var stamp: String
    @Binding var showSavePopup: Bool
    var mode: SaveMode = .create
    var existingMemory: Memory? = nil
    var album: Album?
    
    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .init(width: 0, height: 0)
    @State private var lastOffset: CGSize = .init(width: 0, height: 0)
    @State private var lastScale: CGFloat = 1
    @State private var titleText = ""
    @State private var noteText = ""
    @State private var savedImage: UIImage?
    @State private var selectedFrameIndex: Int = 0
    @State private var maskBounds: CGRect = .zero
    
    private let canvasSize = CGSize(width: 500, height: 500)
    private let maskScaleFactor: CGFloat = 0.55
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 3
    
    let frames = ["stamp_frame_1", "stamp_frame_2", "stamp_frame_3", "polaroid_frame_1", "polaroid_frame_2", "polaroid_frame_3"]
    let stamps = ["stamp_1", "stamp_2", "stamp_3", "polaroid_frame_1", "polaroid_frame_2", "polaroid_frame_3"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack {
                        if mode == .create {
                            if let image = currentImage {
                                imageView(image)
                            }
                        } else {
                            if let data = existingMemory?.imageData,
                               let image = UIImage(data: data) {
                                imageView(image)
                            }
                        }
                        
                        mode == .create ?
                        Text("Adjust the image as you like")
                            .font(.caption2)
                            .italic()
                            .foregroundStyle(.tertiary)
                        : nil
                    }
                    .padding(.top, 48)
                    .padding(.bottom, 24)
                    
                    if mode == .create {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(frames, id: \.self) { frame in
                                    HStack {
                                        Image(frame)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50)
                                            .onTapGesture {
                                                selectedFrameIndex = frames.firstIndex(of: frame) ?? 0
                                            }
                                            .padding()
                                    }
                                }
                            }
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                            .ignoresSafeArea()
                            .background(Color.gray.opacity(0.5))
                            .onChange(of: selectedFrameIndex) { _, newValue in
                                stamp = stamps[newValue]
                            }
                        }
                    }
                    
                    VStack {
                        VStack(alignment: .leading) {
                            HStack(spacing: 2) {
                                Text("Title")
                                    .font(.title3)
                                    .fontWeight(.medium)
                                
                                Text("*")
                                    .foregroundStyle(Color.red)
                            }
                            
                            TextField("Meow", text: $titleText)
                                .padding(16)
                                .background(.regularMaterial)
                                .cornerRadius(20)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Note (max. 30 words)")
                                .font(.title3)
                                .fontWeight(.medium)
                            
                            TextField("Meow is cat sound", text: $noteText, axis: .vertical)
                                .padding(16)
                                .background(.regularMaterial)
                                .cornerRadius(20)
                                .lineLimit(1...3)
                                .onChange(of: noteText) { _, newValue in
                                    let words = newValue.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
                                    
                                    if words.count > 30 {
                                        noteText = words.prefix(30).joined(separator: " ")
                                    }
                                }
                        }
                        
                        Button(action: {
                            if mode == .create {
                                createMemory()
                            } else {
                                updateMemory()
                            }
                        }) {
                            HStack {
                                Image(systemName: "photo.artframe")
                                
                                Text(mode == .create ? "Save" : "Update")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .disabled(titleText.trimmingCharacters(in: .whitespaces).isEmpty)
                        .padding(.top)
                        
                        Button("Cancel") {
                            showSavePopup = false
                        }
                        .padding(.vertical)
                    }
                    .padding(.horizontal)
                }
                .onAppear() {
                    loadExistingMemory()
                }
                .onChange(of: existingMemory) { _, _ in
                    loadExistingMemory()
                }
            }
            .navigationTitle("Save Memory")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    func createMemory() {
        if let image = currentImage {
            if let mask = UIImage(named: stamp) {
                let final = renderFinalImage(
                    photo: image,
                    maskImage: mask,
                    scale: scale,
                    offset: offset,
                    canvasSize: CGSize(width: 500, height: 500)
                )
                savedImage = final
                
                let memory = Memory(image: final, title: titleText, note: noteText, date: Date(), stamp: stamp)
                
                context.insert(memory)
                
                let photo = Photo(position: CGPoint(x: 200, y: 350), scale: 1, rotation: Angle(degrees: 0), memory: memory, albums: album != nil ? [album!] : [])
                
                withAnimation(.spring()) {
                    context.insert(photo)
                    
                    if let album = album {
                        album.photos.append(photo)
                    }
                }
            }
        }
        showSavePopup = false
    }
    
    func isPolaroid(stamp: String) -> Bool {
        return stamp.contains("polaroid")
    }
    
    @ViewBuilder
    func imageView(_ image: UIImage) -> some View {
        Group {
            if isPolaroid(stamp: stamp), let config = polaroidConfig(for: stamp) {
                ZStack(alignment: .center) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width:  config.photoRect.width  * (mode == .create ? scale : 1),
                            height: config.photoRect.height * (mode == .create ? scale : 1)
                        )
                        .offset(mode == .create ? offset : .zero)
                        .frame(width: config.photoRect.width, height: config.photoRect.height, alignment: .center)
                        .clipped()
                        .simultaneousGesture(mode == .create ? dragGesture() : nil)
                        .simultaneousGesture(mode == .create ? magnifyGesture() : nil)
                        .padding(EdgeInsets(
                            top:      config.photoRect.origin.y,
                            leading:  config.photoRect.origin.x,
                            bottom:   config.frameSize.height - config.photoRect.maxY,
                            trailing: config.frameSize.width  - config.photoRect.maxX
                        ))

                    Image(stamp)
                        .resizable()
                        .scaledToFill()
                        .frame(width: config.frameSize.width, height: config.frameSize.height)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                        .allowsHitTesting(false)
                }
                .frame(width: config.photoRect.width, height: config.photoRect.height)
            } else {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(mode == .create ? scale : 1)
                        .offset(mode == .create ? offset : .zero)
                        .simultaneousGesture(mode == .create ? dragGesture() : nil)
                        .simultaneousGesture(mode == .create ? magnifyGesture() : nil)
                }
                .if(mode == .create) { view in
                    view
                        .frame(width: 500, height: 500)
                        .clipped()
                        .mask {
                            Image(stamp)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(0.55)
                        }
                }
                .frame(width: maskBounds.width, height: maskBounds.height)
                .clipped()
            }
        }
        .onAppear { maskBounds = calculateMaskBounds() }
        .onChange(of: stamp) { _, _ in maskBounds = calculateMaskBounds() }
    }

    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { value in
                let newOffset = CGSize(
                    width:  lastOffset.width  + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
                offset = clampOffset(newOffset, scale: scale)
            }
            .onEnded { _ in lastOffset = offset }
    }

    private func magnifyGesture() -> some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = lastScale * value
                scale  = clampScale(newScale)
                offset = clampOffset(offset, scale: scale)
            }
            .onEnded { _ in
                lastScale  = scale
                lastOffset = offset
            }
    }
    
    func updateMemory() {
        guard let memory = existingMemory else { return }
        
        memory.title = titleText
        memory.note = noteText
        
        showSavePopup = false
    }
    
    func loadExistingMemory() {
        guard mode == .edit, let memory = existingMemory else { return }
        
        titleText = memory.title
        noteText = memory.note
        stamp = memory.stamp
        
        if mode == .edit, let data = existingMemory?.imageData {
            savedImage = UIImage(data: data)
        }
    }
    
    func clampScale(_ newScale: CGFloat) -> CGFloat {
        return min(maxScale, max(minScale, newScale))
    }
    
    func clampOffset(_ proposedOffset: CGSize, scale: CGFloat) -> CGSize {
        if isPolaroid(stamp: stamp), let config = polaroidConfig(for: stamp) {
            let photoRect = config.photoRect

            let photo: UIImage? = {
                if mode == .create { return currentImage }
                if let data = existingMemory?.imageData { return UIImage(data: data) }
                return nil
            }()

            guard let photo else { return proposedOffset }

            let aspectWidth  = photoRect.width  / photo.size.width
            let aspectHeight = photoRect.height / photo.size.height
            let baseFillScale = max(aspectWidth, aspectHeight)

            let scaledWidth  = photo.size.width  * baseFillScale * scale
            let scaledHeight = photo.size.height * baseFillScale * scale

            let horizontalLimit = max(0, (scaledWidth  - photoRect.width)  / 2)
            let verticalLimit   = max(0, (scaledHeight - photoRect.height) / 2)

            return CGSize(
                width:  min(max(proposedOffset.width,  -horizontalLimit), horizontalLimit),
                height: min(max(proposedOffset.height, -verticalLimit),   verticalLimit)
            )

        } else {
            let maskBounds = calculateMaskBounds()

            let maskCenterX = maskBounds.midX
            let maskCenterY = maskBounds.midY
            let canvasCenterX = canvasSize.width  / 2
            let canvasCenterY = canvasSize.height / 2

            let deltaX = maskCenterX - canvasCenterX
            let deltaY = maskCenterY - canvasCenterY

            let adjustedOffset = CGSize(
                width:  proposedOffset.width  + deltaX,
                height: proposedOffset.height + deltaY
            )

            let scaledImageWidth  = canvasSize.width  * scale
            let scaledImageHeight = canvasSize.height * scale

            let horizontalLimit = max(0, (scaledImageWidth  - maskBounds.width)  / 2)
            let verticalLimit   = max(0, (scaledImageHeight - maskBounds.height) / 2)

            let clampedX = min(max(adjustedOffset.width,  -horizontalLimit), horizontalLimit)
            let clampedY = min(max(adjustedOffset.height, -verticalLimit),   verticalLimit)

            return CGSize(width: clampedX - deltaX, height: clampedY - deltaY)
        }
    }
    
    func calculateMaskBounds() -> CGRect {
        guard let maskImage = UIImage(named: stamp) else {
            return .zero
        }
        
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
        
        maskWidth *= maskScaleFactor
        maskHeight *= maskScaleFactor
        
        return CGRect(
            x: (canvasSize.width - maskWidth) / 2,
            y: (canvasSize.height - maskHeight) / 2,
            width: maskWidth,
            height: maskHeight
        )
    }
    
    func renderFinalImage(
        photo: UIImage,
        maskImage: UIImage,
        scale: CGFloat,
        offset: CGSize,
        canvasSize: CGSize
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: canvasSize, format: format)

        if isPolaroid(stamp: stamp), let config = polaroidConfig(for: stamp) {
            let image = renderer.image { context in
                let cg = context.cgContext

                let frameOriginX = (canvasSize.width  - config.frameSize.width)  / 2
                let frameOriginY = (canvasSize.height - config.frameSize.height) / 2

                let photoDestRect = CGRect(
                    x: frameOriginX + config.photoRect.origin.x,
                    y: frameOriginY + config.photoRect.origin.y,
                    width: config.photoRect.width,
                    height: config.photoRect.height
                )

                cg.saveGState()
                cg.clip(to: photoDestRect)

                let photoCenter = CGPoint(
                    x: photoDestRect.midX + offset.width,
                    y: photoDestRect.midY + offset.height
                )

                let aspectWidth  = photoDestRect.width  / photo.size.width
                let aspectHeight = photoDestRect.height / photo.size.height
                let fillScale    = max(aspectWidth, aspectHeight) * scale

                let drawWidth  = photo.size.width  * fillScale
                let drawHeight = photo.size.height * fillScale

                let drawRect = CGRect(
                    x: photoCenter.x - drawWidth  / 2,
                    y: photoCenter.y - drawHeight / 2,
                    width: drawWidth,
                    height: drawHeight
                )
                photo.draw(in: drawRect)
                cg.restoreGState()

                let frameDestRect = CGRect(
                    origin: CGPoint(x: frameOriginX, y: frameOriginY),
                    size: config.frameSize
                )
                maskImage.draw(in: frameDestRect)
            }

            let scaleFactor = image.scale
            let cropRect = CGRect(
                x: ((canvasSize.width  - config.frameSize.width)  / 2) * scaleFactor,
                y: ((canvasSize.height - config.frameSize.height) / 2) * scaleFactor,
                width:  config.frameSize.width  * scaleFactor,
                height: config.frameSize.height * scaleFactor
            )
            if let cropped = image.cgImage?.cropping(to: cropRect) {
                return UIImage(cgImage: cropped, scale: scaleFactor, orientation: image.imageOrientation)
            }
            return image
        }

        var maskRect: CGRect = .zero

        let image = renderer.image { context in
            let cg = context.cgContext

            let maskAspect  = maskImage.size.width / maskImage.size.height
            let canvasAspect = canvasSize.width / canvasSize.height

            var maskWidth:  CGFloat
            var maskHeight: CGFloat

            if maskAspect > canvasAspect {
                maskWidth  = canvasSize.width
                maskHeight = canvasSize.width / maskAspect
            } else {
                maskHeight = canvasSize.height
                maskWidth  = canvasSize.height * maskAspect
            }

            let scaleEffect: CGFloat = 0.55
            maskWidth  *= scaleEffect
            maskHeight *= scaleEffect

            let maskOrigin = CGPoint(
                x: (canvasSize.width  - maskWidth)  / 2,
                y: (canvasSize.height - maskHeight) / 2
            )
            maskRect = CGRect(origin: maskOrigin, size: CGSize(width: maskWidth, height: maskHeight))

            if let maskCG = maskImage.cgImage {
                cg.saveGState()
                cg.clip(to: maskRect, mask: maskCG)
            }

            cg.scaleBy(x: scale, y: scale)
            cg.translateBy(
                x: (canvasSize.width  / 2 + offset.width)  / scale,
                y: (canvasSize.height / 2 + offset.height) / scale
            )

            let aspectWidth  = canvasSize.width  / photo.size.width
            let aspectHeight = canvasSize.height / photo.size.height
            let fillScale    = max(aspectWidth, aspectHeight)

            let drawWidth  = photo.size.width  * fillScale
            let drawHeight = photo.size.height * fillScale

            photo.draw(in: CGRect(x: -drawWidth / 2, y: -drawHeight / 2,
                                  width: drawWidth, height: drawHeight))
            cg.restoreGState()
        }

        let scaleFactor = image.scale
        let scaledRect = CGRect(
            x: maskRect.origin.x * scaleFactor,
            y: maskRect.origin.y * scaleFactor,
            width:  maskRect.size.width  * scaleFactor,
            height: maskRect.size.height * scaleFactor
        )
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return image }
        return UIImage(cgImage: cgImage, scale: scaleFactor, orientation: image.imageOrientation)
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        @ViewBuilder transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    let mockAlbum = Album(colorData: Data(), imageData: Data(), name: "Preview Album", date: Date(), photos: [])
    SavePopupSheet(
        currentImage: UIImage(named: "temp"),
        stamp: .constant("polaroid_frame_1"),
        showSavePopup: .constant(true),
        album: mockAlbum
    )
}

