//
//  DraggableStamp.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 17/04/26.
//

import SwiftUI

struct DraggablePhoto: View {
    var photo: Photo
    
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
            }
        }
        .position(photo.position)
        .scaleEffect(photo.scale)
        .rotationEffect(photo.rotationAngle)
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
                
                let dragValue = value.first?.first
                let scaleValue = value.first?.second
                let rotationValue = value.second
                
                if let dragValue {
                    let t = dragValue.translation
                    let angle = photo.rotationAngle.radians
                    let adjustedX = t.width * cos(angle) + t.height * sin(angle)
                    let adjustedY = -t.width * sin(angle) + t.height * cos(angle)
                    let safeScale = max(photo.scale, 0.5)
                    let damping = 1 / sqrt(safeScale)

                    photo.posX = lastPosition.x + adjustedX * damping
                    photo.posY = lastPosition.y + adjustedY * damping          
                }
                
                if let scaleValue {
                    let newScale = lastScale * scaleValue
                    
                    photo.scale = min(max(newScale, 0.5), 3.0)
                }
                
                if let rotationValue {
                    photo.rotation = lastRotation + rotationValue.radians
                }
            }
            .onEnded { _ in
                lastPosition = photo.position
                lastScale = photo.scale
                lastRotation = photo.rotation
            }
    }
}
