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
    var color: String
    var imageData: Data
    var name: String
    var date: Date
    
    @Relationship(deleteRule: .nullify)
    var photos: [Photo]
    
    @Relationship(deleteRule: .nullify)
    var collection: [Collection]
    
    init(id: UUID = UUID(), color: String, imageData: Data, name: String, date: Date, photos: [Photo], collection: [Collection]) {
        self.id = id
        self.color = color
        self.imageData = imageData
        self.name = name
        self.date = date
        self.photos = photos
        self.collection = collection
    }
}
