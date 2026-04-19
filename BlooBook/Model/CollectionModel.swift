//
//  CollectionModel.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 18/04/26.
//

import Foundation
import SwiftUI

struct CollectionModel : Identifiable {
    let id = UUID()
    
    var name: String
    var album: [AlbumModel]
    
    init(name: String, album: [AlbumModel]) {
        self.name = name
        self.album = album
    }
}

extension CollectionModel {
    static let sampleData = [
        CollectionModel(name: "Travels", album: AlbumModel.sampleData),
        CollectionModel(name: "Fams", album: AlbumModel.sampleData),
        CollectionModel(name: "Friends", album: AlbumModel.sampleData),
        CollectionModel(name: "Foods", album: AlbumModel.sampleData),
    ]
}
