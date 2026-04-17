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
        
            .gesture(
                DragGesture()
                    .onChanged { value in
                        stamp.position = CGPoint(
                            x: lastPosition.x + value.translation.width,
                            y: lastPosition.y + value.translation.height
                        )
                    }
                    .onEnded { _ in
                        lastPosition = stamp.position
                    }
            )
            .simultaneousGesture(
                MagnificationGesture()
                    .onChanged { value in
                        stamp.scale = lastScale * value
                    }
                    .onEnded { _ in
                        lastScale = stamp.scale
                    }
            )
            .simultaneousGesture(
                RotationGesture()
                    .onChanged { value in
                        stamp.rotation = lastRotation + value
                    }
                    .onEnded { _ in
                        lastRotation = stamp.rotation
                    }
            )
    }
}
