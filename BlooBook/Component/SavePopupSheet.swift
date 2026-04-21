//
//  SavePopupView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 17/04/26.
//

import SwiftUI
import SwiftData

struct SavePopupSheet: View {
    @Environment(\.modelContext) private var context
    
    var currentImage: UIImage?
    @Binding var stamp: String
    @Binding var showSavePopup: Bool
    
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
    
    private let frames = ["stamp_frame_1", "stamp_frame_2", "stamp_frame_3"]
    private let stamps = ["stamp_1", "stamp_2", "stamp_3"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Save Memory")
                    .font(.title)
                    .bold()
                    .padding(.top)
                
                VStack {
                    if let image = currentImage {
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .scaleEffect(scale)
                                .offset(offset)
                                .simultaneousGesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let newOffset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                            offset = clampOffset(newOffset, scale: scale)
                                        }
                                        .onEnded{ _ in lastOffset = offset }
                                )
                                .simultaneousGesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let newScale = lastScale * value
                                            scale = clampScale(newScale)
                                            
                                            offset = clampOffset(offset, scale: scale)
                                        }
                                        .onEnded { _ in
                                            lastScale = scale
                                            lastOffset = offset
                                        }
                                )
                        }
                        .frame(width: 500, height: 500)
                        .clipped()
                        .mask {
                            Image(stamp)
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(0.55)
                        }
                        .onAppear {
                            maskBounds = calculateMaskBounds()
                        }
                        .onChange(of: stamp) { _, _ in
                            maskBounds = calculateMaskBounds()
                        }
                        .frame(
                            width: maskBounds.width,
                            height: maskBounds.height
                        )
                        .clipped()
                    }
                    
                    Text("Adjust the image as you like")
                        .font(.caption2)
                        .italic()
                        .foregroundStyle(.tertiary)
                }
                
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
                                
                                let memory = Memory(image: final, title: titleText, note: noteText, date: Date())
                                
                                context.insert(memory)
                            }
                        }
                        showSavePopup = false
                    }) {
                        HStack {
                            Image(systemName: "photo.artframe")
                            
                            Text("Save")
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
        }
    }
    
    func clampScale(_ newScale: CGFloat) -> CGFloat {
        return min(maxScale, max(minScale, newScale))
    }
    
    func clampOffset(_ proposedOffset: CGSize, scale: CGFloat) -> CGSize {
        let maskBounds = calculateMaskBounds()
        
        let maskCenterX = maskBounds.midX
        let maskCenterY = maskBounds.midY
        
        let canvasCenterX = canvasSize.width / 2
        let canvasCenterY = canvasSize.height / 2
        
        let deltaX = maskCenterX - canvasCenterX
        let deltaY = maskCenterY - canvasCenterY
        
        let adjustedOffset = CGSize(
            width: proposedOffset.width + deltaX,
            height: proposedOffset.height + deltaY
        )
        
        let scaledImageWidth = canvasSize.width * scale
        let scaledImageHeight = canvasSize.height * scale
        
        let horizontalLimit = max(0, (scaledImageWidth - maskBounds.width) / 2)
        let verticalLimit = max(0, (scaledImageHeight - maskBounds.height) / 2)
        
        let clampedX = min(max(adjustedOffset.width, -horizontalLimit), horizontalLimit)
        let clampedY = min(max(adjustedOffset.height, -verticalLimit), verticalLimit)
        
        return CGSize(width: clampedX - deltaX, height: clampedY - deltaY)
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
            
            cg.scaleBy(x: scale, y: scale)
            
            cg.translateBy(
                x: (canvasSize.width / 2 + offset.width) / scale,
                y: (canvasSize.height / 2 + offset.height) / scale
            )
            
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
    SavePopupSheet(
        currentImage: UIImage(named: "temp"),
        stamp: .constant("stamp_1"),
        showSavePopup: .constant(true)
    )
}

