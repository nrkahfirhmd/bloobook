//
//  DraggableStamp.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 17/04/26.
//

import SwiftUI

struct DraggableStamp: View {
    
    @Binding var stamp: StampModel
    
    @State private var lastPosition: CGPoint = .zero
    @State private var lastScale: CGFloat = 1
    @State private var lastRotation: Angle = .zero
    
    var body: some View {
        PhotoStamp(photo: stamp)
            .position(stamp.position)
            .scaleEffect(stamp.scale)
            .rotationEffect(stamp.rotation)
            
            .onAppear {
                lastPosition = stamp.position
                lastScale = stamp.scale
                lastRotation = stamp.rotation
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
                    let angle = stamp.rotation.radians

                    let adjustedX = t.width * cos(angle) + t.height * sin(angle)
                    let adjustedY = -t.width * sin(angle) + t.height * cos(angle)
                    let damping = 1 / sqrt(stamp.scale)

                    stamp.position = CGPoint(
                        x: lastPosition.x + adjustedX * damping,
                        y: lastPosition.y + adjustedY * damping
                    )
                    
                }
                
                if let scaleValue {
                    let newScale = lastScale * scaleValue

                    stamp.scale = min(max(newScale, 0.5), 3.0)
                }
                
                if let rotationValue {
                    stamp.rotation = lastRotation + rotationValue
                }
            }
            .onEnded { _ in
                lastPosition = stamp.position
                lastScale = stamp.scale
                lastRotation = stamp.rotation
            }
    }
}
