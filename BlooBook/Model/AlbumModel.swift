//
//  AlbumModel.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 17/04/26.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Album {
    var id = UUID()
    var colorData: Data
    var imageData: Data
    var name: String
    var date: Date
    
    @Relationship(inverse: \Photo.albums)
    var photos: [Photo]
    
    var collections: [Collection] = []
    
    init(colorData: Data, imageData: Data, name: String, date: Date, photos: [Photo]) {
        self.colorData = colorData
        self.imageData = imageData
        self.name = name
        self.date = date
        self.photos = photos
    }
}

extension Album {
    var color: Color {
        colorData.toColor() ?? .gray
    }
}


