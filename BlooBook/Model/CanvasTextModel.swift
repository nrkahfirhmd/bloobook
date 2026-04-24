//
//  CanvasTextModel.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 23/04/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class CanvasText {
    var id = UUID()
    var text: TextContent
    var posX: Double
    var posY: Double
    var scale: Double
    var rotation: Double
    
    @Relationship(deleteRule: .nullify)
    var albums: [Album] = []
    
    init(id: UUID = UUID(), text: TextContent, position: CGPoint, scale: CGFloat, rotation: Angle, albums: [Album]) {
        self.id = id
        self.text = text
        self.posX = position.x
        self.posY = position.y
        self.scale = Double(scale)
        self.rotation = rotation.radians
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

@Model
class TextContent {
    var id: UUID = UUID()
    var content: String
    var fontName: String
    var fontSize: Double
    var isBold: Bool
    var isItalic: Bool
    
    init(content: String, fontName: String = "Helvetica", fontSize: Double = 24, isBold: Bool = false, isItalic: Bool = false) {
        self.content = content
        self.fontName = fontName
        self.fontSize = fontSize
        self.isBold = isBold
        self.isItalic = isItalic
    }
}
