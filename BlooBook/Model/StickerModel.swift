//
//  StickerModel.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 23/04/26.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Sticker {
    var id = UUID()
    var imageData: Data
    var posX: Double
    var posY: Double
    var scale: Double
    var rotation: Double
    var url: URL
    
    @Relationship(deleteRule: .nullify)
    var albums: [Album] = []
    
    init(id: UUID = UUID(), image: UIImage, position: CGPoint, scale: CGFloat, rotation: Angle, albums: [Album], url: URL) {
        self.id = id
        if let pngData = image.pngData() {
            self.imageData = Self.compressData(pngData)
        } else {
            self.imageData = Data()
        }
        self.posX = position.x
        self.posY = position.y
        self.scale = Double(scale)
        self.rotation = rotation.radians
        self.albums = albums
        self.url = url
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
    
    private static func compressData(_ data: Data) -> Data {
        if let image = UIImage(data: data) {
            let hasAlpha = image.cgImage?.alphaInfo == .first ||
                           image.cgImage?.alphaInfo == .last ||
                           image.cgImage?.alphaInfo == .premultipliedFirst ||
                           image.cgImage?.alphaInfo == .premultipliedLast

            if !hasAlpha, let jpegData = image.jpegData(compressionQuality: 0.7) {
                return jpegData
            }
        
            if let pngData = image.pngData() {
                return pngData
            }
        }
        
        return data
    }
}
