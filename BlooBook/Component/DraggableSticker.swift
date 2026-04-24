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
    @Binding var draggingSticker: Sticker?
    @Binding var isDragging: Bool
    @Binding var isOverTrash: Bool
    @Binding var trashFrame: CGRect
    
    @State private var trashScaleEffect: CGFloat = 1
    @State private var lastPosition: CGPoint = .zero
    @State private var lastScale: CGFloat = 1
    @State private var lastRotation: Double = 0
    
    var body: some View {
        Group
        {
            if let uiImage = UIImage(data: sticker.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
            }
        }
        .position(sticker.position)
        .rotationEffect(sticker.rotationAngle)
        .scaleEffect(sticker.scale * trashScaleEffect)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trashScaleEffect)
        .onAppear {
            lastPosition = sticker.position
            lastScale = sticker.scale
            lastRotation = sticker.rotation
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
                
                draggingSticker = sticker
                isDragging = true
                
                let dragValue = value.first?.first
                let scaleValue = value.first?.second
                let rotationValue = value.second
                
                if let dragValue {
                    let t = dragValue.translation
                    let angle = lastRotation
                    
                    let adjustedX = t.width * cos(angle) + t.height * sin(angle)
                    let adjustedY = -t.width * sin(angle) + t.height * cos(angle)
                    
                    let damping = 1 / sqrt(max(sticker.scale, 0.5))
                    
                    sticker.posX = lastPosition.x + adjustedX * damping
                    sticker.posY = lastPosition.y + adjustedY * damping
                    
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
                        sticker.posX += (trashFrame.midX - sticker.posX - 100) * lerp
                        sticker.posY += (trashFrame.midY - sticker.posY - 100) * lerp
                    }
                }
                
                if let scaleValue {
                    let newScale = lastScale * scaleValue
                    sticker.scale = min(max(newScale, 0.75), 3.0)
                }
                
                if let rotationValue {
                    sticker.rotation = lastRotation + rotationValue.radians
                }
            }
            .onEnded { _ in
                
                if isOverTrash {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        sticker.posX = trashFrame.midX
                        sticker.posY = trashFrame.midY
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        deleteSticker()
                    }
                }
                
                trashScaleEffect = 1
                isDragging = false
                isOverTrash = false
                draggingSticker = nil
                
                lastPosition = sticker.position
                lastScale = sticker.scale
                lastRotation = sticker.rotation
            }
    }
    
    func deleteSticker() {
        context.delete(sticker)
    }
}
