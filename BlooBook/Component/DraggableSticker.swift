//
//  DraggableSticker.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 24/04/26.
//

import SwiftUI
import SwiftData

struct DraggableSticker: View {
    @Environment(\.modelContext) private var context
    
    @Bindable var sticker: Sticker
    @Binding var draggingStickerID: UUID?
    @Binding var isDragging: Bool
    @Binding var isOverTrash: Bool
    @Binding var trashFrame: CGRect
    
    @State private var trashScaleEffect: CGFloat = 1
    @State private var lastPosition: CGPoint = .zero
    @State private var lastScale: CGFloat = 1
    @State private var lastRotation: Double = 0
    @State private var currentPosition: CGPoint = .zero
    @State private var currentScale: CGFloat = 1
    @State private var currentRotation: Angle = .zero
    @State private var displayImage: UIImage?
    
    var body: some View {
        Group
        {
            if let displayImage {
                Image(uiImage: displayImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            } else if let uiImage = UIImage(data: sticker.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }
        }
        .rotationEffect(currentRotation)
        .scaleEffect(currentScale * trashScaleEffect)
        .position(currentPosition)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trashScaleEffect)
        .onAppear {
            syncFromModel()
            if displayImage == nil {
                displayImage = UIImage(data: sticker.imageData)
            }
        }
        .onChange(of: sticker.imageData) { _, newValue in
            displayImage = UIImage(data: newValue)
        }
        .onChange(of: sticker.posX) { _, _ in
            if draggingStickerID != sticker.id {
                syncFromModel()
            }
        }
        .onChange(of: sticker.posY) { _, _ in
            if draggingStickerID != sticker.id {
                syncFromModel()
            }
        }
        .onChange(of: sticker.scale) { _, _ in
            if draggingStickerID != sticker.id {
                syncFromModel()
            }
        }
        .onChange(of: sticker.rotation) { _, _ in
            if draggingStickerID != sticker.id {
                syncFromModel()
            }
        }
        .gesture(combinedGesture)
    }
    
    var combinedGesture: some Gesture {
        let drag = DragGesture()
        let scale = MagnificationGesture()
        let rotate = RotationGesture()
        
        return drag
            .simultaneously(with: scale)
            .simultaneously(with: rotate)
            .onChanged { value in
                if draggingStickerID != sticker.id {
                    draggingStickerID = sticker.id
                }
                if !isDragging {
                    isDragging = true
                }
                
                let dragValue = value.first?.first
                let scaleValue = value.first?.second
                let rotationValue = value.second
                
                if let dragValue {
                    let t = dragValue.translation
                    let damping = 1 / sqrt(max(sticker.scale, 0.5))

                    currentPosition = CGPoint(
                        x: lastPosition.x + t.width * damping,
                        y: lastPosition.y + t.height * damping
                    )
                    
                    let touchPoint = dragValue.location
                    let expandedTrash = trashFrame.insetBy(dx: -20, dy: -150)
                    
                    let newIsOverTrash = expandedTrash.contains(touchPoint)
                    
                    if newIsOverTrash != isOverTrash {
                        isOverTrash = newIsOverTrash
                        
                        if isOverTrash {
                            let targetScale: CGFloat = 0.5
                            trashScaleEffect = targetScale / max(sticker.scale, 0.5)
                            
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        } else {
                            trashScaleEffect = 1
                        }
                    }
                    
                    if isOverTrash {
                        let lerp: CGFloat = 0.2
                        currentPosition.x += (trashFrame.midX - currentPosition.x) * lerp
                        currentPosition.y += (trashFrame.midY - currentPosition.y) * lerp
                    }
                }
                
                if let scaleValue {
                    let newScale = lastScale * scaleValue
                    currentScale = min(max(newScale, 0.75), 3.0)
                }
                
                if let rotationValue {
                    currentRotation = Angle(radians: lastRotation + rotationValue.radians)
                }
            }
            .onEnded { _ in
                if isOverTrash {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        currentPosition = CGPoint(x: trashFrame.midX, y: trashFrame.midY)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        deleteSticker()
                    }
                } else {
                    sticker.posX = currentPosition.x
                    sticker.posY = currentPosition.y
                    sticker.scale = currentScale
                    sticker.rotation = currentRotation.radians
                }
                
                trashScaleEffect = 1
                isDragging = false
                isOverTrash = false
                draggingStickerID = nil
                
                lastPosition = currentPosition
                lastScale = currentScale
                lastRotation = currentRotation.radians
            }
    }
    
    func deleteSticker() {
        context.delete(sticker)
    }

    private func syncFromModel() {
        let position = sticker.position
        let scale = sticker.scaleCGFloat
        let rotation = sticker.rotationAngle

        lastPosition = position
        lastScale = scale
        lastRotation = rotation.radians
        currentPosition = position
        currentScale = scale
        currentRotation = rotation
    }
}
