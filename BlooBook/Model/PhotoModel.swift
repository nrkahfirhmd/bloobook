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
    
    var positionX: Double
    var positionY: Double
    var scale: CGFloat = 1
    var rotation: Angle = Angle(degrees: 0)
    
    var memory: Memory
    
    var albums: [Album] = []
    
    init(position: CGPoint, memory: Memory) {
        self.positionX = position.x
        self.positionY = position.y
        self.memory = memory
    }
}

extension Photo {
    var position: CGPoint {
        get {
            CGPoint(x: positionX, y: positionY)
        }
        set {
            positionX = newValue.x
            positionY = newValue.y
        }
    }
}
