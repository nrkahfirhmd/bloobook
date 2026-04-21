//
//  StampModel.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 17/04/26.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Photo {
    var id = UUID()
    
    var posX: Double
    var posY: Double
    var scale: Double
    var rotation: Double
    
    var memory: Memory
    
    @Relationship(deleteRule: .nullify)
    var albums: [Album] = []
    
    init(position: CGPoint, scale: CGFloat, rotation: Angle, memory: Memory, albums: [Album]) {
        self.posX = position.x
        self.posY = position.y
        self.scale = Double(scale)
        self.rotation = rotation.radians
        self.memory = memory
        self.albums = albums
    }
    
    var position: CGPoint {
        CGPoint(x: posX, y: posY)
    }
    
    var rotationAngle: Angle {
        Angle(radians: rotation)
    }
    
    var scaleCGFloat: CGFloat {
        CGFloat(scale)
    }
}
