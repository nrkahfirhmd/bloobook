//
//  StampModel.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 17/04/26.
//

import Foundation
import SwiftUI

struct StampModel: Identifiable {
    let id = UUID()
    
    var position: CGPoint
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
    
    var image: UIImage?         
    var source: ImageResource?
    var stamp: ImageResource
    
    init(position: CGPoint, image: UIImage? = nil, source: ImageResource? = nil, stamp: ImageResource) {
        self.position = position
        self.image = image
        self.source = source
        self.stamp = stamp
    }
}

extension StampModel {
    static let sampleData = [
        StampModel(
            position: CGPoint(x: 200, y: 300),
            source: .photo1,
            stamp: .stampVertical
        ),
        StampModel(
            position: CGPoint(x: 200, y: 300),
            source: .photo2,
            stamp: .stampVertical
        ),
        StampModel(
            position: CGPoint(x: 200, y: 300),
            source: .photo3,
            stamp: .stampVertical
        ),
        StampModel(
            position: CGPoint(x: 200, y: 300),
            source: .photo4,
            stamp: .stampVertical
        ),
        StampModel(
            position: CGPoint(x: 200, y: 300),
            source: .photo5,
            stamp: .stampVertical
        )
    ]
}
