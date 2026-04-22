//
//  MemoryModel.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 17/04/26.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Memory {
    var id = UUID()
    var imageData: Data
    var title: String
    var note: String
    var date: Date
    var stamp: String = "stamp_1"
    
    init(image: UIImage, title: String, note: String, date: Date, stamp: String) {
        self.id = UUID()
        if let pngData = image.pngData() {
            self.imageData = Self.compressData(pngData)
        } else {
            self.imageData = Data()
        }
        self.title = title
        self.note = note
        self.date = date
        self.stamp = stamp
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
