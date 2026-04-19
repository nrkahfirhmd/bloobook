//
//  AlbumModel.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 17/04/26.
//

import Foundation
import SwiftUI

struct AlbumModel : Identifiable{
    let id = UUID()
    var color: Color
    var image: UIImage
    var name: String
    var date: Date
    
    init(color: Color, image: UIImage, name: String, date: Date) {
        self.color = color
        self.image = image
        self.name = name
        self.date = date
    }
}

extension AlbumModel{
    static let sampleData: [AlbumModel] = [
        AlbumModel(color: .blue, image: .photo1, name: "Batur", date: Date.now),
        AlbumModel(color: .red, image: .photo2, name: "Me & Batur", date: Date.now),
        AlbumModel(color: .gray, image: .photo3, name: "Challenge 1", date: Date.now),
        AlbumModel(color: .cyan, image: .photo4, name: "Cohort '26", date: Date.now),
        AlbumModel(color: .brown, image: .photo5, name: "Plenger", date: Date.now),
    ]
}
