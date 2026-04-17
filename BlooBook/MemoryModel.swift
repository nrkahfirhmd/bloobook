//
//  MemoryModel.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 17/04/26.
//
import Foundation
import SwiftUI

struct Memory: Identifiable {
    let id = UUID()
    let image: UIImage
    let title: String
    let note: String
    let date: Date
}
