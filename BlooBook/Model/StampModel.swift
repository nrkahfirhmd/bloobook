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
}
