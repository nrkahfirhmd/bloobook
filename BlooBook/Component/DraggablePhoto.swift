//
//  DraggableStamp.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 17/04/26.
//

import SwiftUI
import SwiftData

struct DraggablePhoto: View {
    var photo: Photo
    @Environment(\.modelContext) private var context
    @Binding var draggingPhoto: Photo?
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
            if let uiImage = UIImage(data: photo.memory.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
            }
        }
        .position(photo.position)
        .rotationEffect(photo.rotationAngle)
        .scaleEffect(photo.scale * trashScaleEffect)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trashScaleEffect)
        .onAppear {
            lastPosition = photo.position
            lastScale = photo.scale
            lastRotation = photo.rotation
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
                
                draggingPhoto = photo
                isDragging = true
                
                let dragValue = value.first?.first
                let scaleValue = value.first?.second
                let rotationValue = value.second
                
                if let dragValue {
                    let t = dragValue.translation
                    let angle = lastRotation
                    
                    let adjustedX = t.width * cos(angle) + t.height * sin(angle)
                    let adjustedY = -t.width * sin(angle) + t.height * cos(angle)
                    
                    let damping = 1 / sqrt(max(photo.scale, 0.5))
                    
                    photo.posX = lastPosition.x + adjustedX * damping
                    photo.posY = lastPosition.y + adjustedY * damping
                    
                    let touchPoint = dragValue.location
                    let expandedTrash = trashFrame.insetBy(dx: -20, dy: -150)
                    
                    let newIsOverTrash = expandedTrash.contains(touchPoint)
                    
                    if newIsOverTrash != isOverTrash {
                        isOverTrash = newIsOverTrash
                        
                        if isOverTrash {
                            let targetScale: CGFloat = 0.5
                            trashScaleEffect = targetScale / max(photo.scale, 0.5)
                            
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        } else {
                            trashScaleEffect = 1
                        }
                    }
                    
                    if isOverTrash {
                        let lerp: CGFloat = 0.2
                        photo.posX += (trashFrame.midX - photo.posX - 100) * lerp
                        photo.posY += (trashFrame.midY - photo.posY - 100) * lerp
                    }
                }
                
                if let scaleValue {
                    let newScale = lastScale * scaleValue
                    photo.scale = min(max(newScale, 0.75), 3.0)
                }
                
                if let rotationValue {
                    photo.rotation = lastRotation + rotationValue.radians
                }
            }
            .onEnded { _ in
                
                if isOverTrash {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        photo.posX = trashFrame.midX
                        photo.posY = trashFrame.midY
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        deletePhoto()
                    }
                }
                
                trashScaleEffect = 1
                isDragging = false
                isOverTrash = false
                draggingPhoto = nil
                
                lastPosition = photo.position
                lastScale = photo.scale
                lastRotation = photo.rotation
            }
    }
    func deletePhoto() {
        context.delete(photo)
    }
    func photoFrame() -> CGRect {
        CGRect(
            x: photo.posX - 75,
            y: photo.posY - 75,
            width: 150,
            height: 150
        )
    }
}
