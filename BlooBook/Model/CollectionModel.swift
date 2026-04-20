//
//  CollectionModel.swift
//  BlooBook
//
// Created by Muhammad Bintang Al-Fath on 18/04/26.
//

import Foundation
import SwiftData

@Model
class Collection {
    var id = UUID()
    var name: String
    
    @Relationship(inverse: \Album.collections)
    var albums: [Album] = []
    
    init(name: String, albums: [Album] = []) {
        self.name = name
        self.albums = albums
    }
}
