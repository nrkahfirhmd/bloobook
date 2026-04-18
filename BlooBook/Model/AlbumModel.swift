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
}
