//
//  SavePopupView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 17/04/26.
//

import SwiftUI

struct SavePopupSheet: View {
    var currentImage: UIImage?
    var stamp: String?
    @Binding var memories: [Memory]
    @Binding var showSavePopup: Bool
    
    @State private var scale: CGFloat = 1
    @State private var offset: CGSize = .init(width: 0, height: 0)
    @State private var lastOffset: CGSize = .init(width: 0, height: 0)
    @State private var lastScale: CGFloat = 1
    @State private var titleText = ""
    @State private var noteText = ""
    @State private var savedImage: UIImage?
    @State private var selectedFrameIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Save Memory")
                .font(.title)
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
                    if let stamp {
                        Image(stamp)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(0.55)
                    }
                }
            }
            
            VStack(alignment: .leading) {
                Text("Title")
                    .font(.title3)
                    .fontWeight(.medium)
                
                VStack(spacing: 0) {
                    TextField("Meow", text: $titleText)
                        .padding(.bottom, 5)
                        .padding(.horizontal, 5)
                    Divider()
                            .background(Color.gray)
                }
            }
            
            VStack(alignment: .leading) {
                Text("Note (max. 100 words)")
                    .font(.title3)
                    .fontWeight(.medium)
                
                ZStack(alignment: .topLeading) {
                    if noteText.isEmpty {
                        Text("Write your note...")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }
                    
                    TextEditor(text: $noteText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.clear)
                }
                .background() {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue.opacity(0.5))
                }
                .frame(height: 150)
            }
            
            Button(action: {
                if let image = currentImage {
                    if let stamp = stamp,
                       let mask = UIImage(named: stamp) {
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
            
            Button("Cancel") {
                showSavePopup = false
            }
            .padding(.vertical)
        }
        .padding()
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
    SavePopupSheet(
           currentImage: UIImage(named: "temp"),
           stamp: "stamp_1",
           memories: .constant([
               Memory(
                   image: UIImage(named: "temp")!,
                   title: "Dynamic Duo",
                   note: "Handsome Duo",
                   date: Date()
               )
           ]),
           showSavePopup: .constant(true)
       )
}
