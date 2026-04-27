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
    @Binding var draggingPhotoID: UUID?
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
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
            } else if let uiImage = UIImage(data: photo.memory.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
            }
        }
        .rotationEffect(currentRotation)
        .scaleEffect(currentScale * trashScaleEffect)
        .position(currentPosition)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trashScaleEffect)
        .onAppear {
            syncFromModel()
            if displayImage == nil {
                displayImage = UIImage(data: photo.memory.imageData)
            }
        }
        .onChange(of: photo.memory.imageData) { _, newValue in
            displayImage = UIImage(data: newValue)
        }
        .onChange(of: photo.posX) { _, _ in
            if draggingPhotoID != photo.id {
                syncFromModel()
            }
        }
        .onChange(of: photo.posY) { _, _ in
            if draggingPhotoID != photo.id {
                syncFromModel()
            }
        }
        .onChange(of: photo.scale) { _, _ in
            if draggingPhotoID != photo.id {
                syncFromModel()
            }
        }
        .onChange(of: photo.rotation) { _, _ in
            if draggingPhotoID != photo.id {
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
                if draggingPhotoID != photo.id {
                    draggingPhotoID = photo.id
                }
                if !isDragging {
                    isDragging = true
                }
                
                let dragValue = value.first?.first
                let scaleValue = value.first?.second
                let rotationValue = value.second
                
                if let dragValue {
                    let t = dragValue.translation
                    let damping = 1 / sqrt(max(photo.scale, 0.5))

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
                            trashScaleEffect = targetScale / max(photo.scale, 0.5)
                            
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        } else {
                            trashScaleEffect = 1
                        }
                    }
                    
                    if isOverTrash {
                        let lerp: CGFloat = 0.2
                        currentPosition.x += (trashFrame.midX - currentPosition.x - 100) * lerp
                        currentPosition.y += (trashFrame.midY - currentPosition.y - 100) * lerp
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
                        deletePhoto()
                    }
                } else {
                    photo.posX = currentPosition.x
                    photo.posY = currentPosition.y
                    photo.scale = currentScale
                    photo.rotation = currentRotation.radians
                }
                
                trashScaleEffect = 1
                isDragging = false
                isOverTrash = false
                draggingPhotoID = nil
                
                lastPosition = currentPosition
                lastScale = currentScale
                lastRotation = currentRotation.radians
            }
    }
    func deletePhoto() {
        context.delete(photo)
    }

    private func syncFromModel() {
        let position = photo.position
        let scale = photo.scaleCGFloat
        let rotation = photo.rotationAngle

        lastPosition = position
        lastScale = scale
        lastRotation = rotation.radians
        currentPosition = position
        currentScale = scale
        currentRotation = rotation
    }
}
