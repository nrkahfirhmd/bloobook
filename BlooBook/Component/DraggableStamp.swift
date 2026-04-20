//
//  DraggableStamp.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 17/04/26.
//

import SwiftUI

struct DraggableStamp: View {
    var photo: Photo
    
    @State private var lastPosition: CGPoint = .zero
    @State private var lastScale: CGFloat = 1
    @State private var lastRotation: Angle = .zero
    
    var body: some View {
        PhotoStamp(photo: photo)
            .position(photo.position)
            .scaleEffect(photo.scale)
            .rotationEffect(photo.rotation)
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
                    let angle = photo.rotation.radians

                    let adjustedX = t.width * cos(angle) + t.height * sin(angle)
                    let adjustedY = -t.width * sin(angle) + t.height * cos(angle)
                    let damping = 1 / sqrt(photo.scale)

                    photo.position = CGPoint(
                        x: lastPosition.x + adjustedX * damping,
                        y: lastPosition.y + adjustedY * damping
                    )
                    
                }
                
                if let scaleValue {
                    let newScale = lastScale * scaleValue

                    photo.scale = min(max(newScale, 0.5), 3.0)
                }
                
                if let rotationValue {
                    photo.rotation = lastRotation + rotationValue
                }
            }
            .onEnded { _ in
                lastPosition = photo.position
                lastScale = photo.scale
                lastRotation = photo.rotation
            }
    }
}
