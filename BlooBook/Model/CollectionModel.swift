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
    
    @Relationship(deleteRule: .nullify)
    var albums: [Album]
    
    init(id: UUID = UUID(), name: String, albums: [Album]) {
        self.id = id
        self.name = name
        self.albums = albums
    }
}
