//
//  PolaroidConfig.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 23/04/26.
//

import SwiftUI

struct PolaroidConfig {
    let frameSize: CGSize
    let photoRect: CGRect
}

func polaroidConfig(for stamp: String) -> PolaroidConfig? {
    switch stamp {
    case "polaroid_frame_1":
        
        return PolaroidConfig(
            frameSize: CGSize(width: 285, height: 347),
            photoRect: CGRect(x: 15.09, y: 20.12, width: 252.71, height: 253.96)
        )
    case "polaroid_frame_2":
        
        return PolaroidConfig(
            frameSize: CGSize(width: 345, height: 276),
            photoRect: CGRect(x: 13.83, y: 22.63, width: 316.83, height: 198.64)
        )
    case "polaroid_frame_3":
        
        return PolaroidConfig(
            frameSize: CGSize(width: 174, height: 277),
            photoRect: CGRect(x: 16.34, y: 22.63, width: 140.81, height: 198.64)
        )
    default:
        return nil
    }
}
