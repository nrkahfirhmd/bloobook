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
    
    var position: CGPoint
    var scale: CGFloat
    var rotation: Angle
    
    var memory: Memory
    
    @Relationship(deleteRule: .nullify)
    var album: [Album]
    
    init(id: UUID = UUID(), position: CGPoint, scale: CGFloat, rotation: Angle, memory: Memory, album: [Album]) {
        self.id = id
        self.position = position
        self.scale = scale
        self.rotation = rotation
        self.memory = memory
        self.album = album
    }
}
