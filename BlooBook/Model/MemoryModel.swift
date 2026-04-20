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
    
    init(image: UIImage, title: String, note: String, date: Date) {
        self.id = UUID()
        self.imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
        self.title = title
        self.note = note
        self.date = date
    }
}
