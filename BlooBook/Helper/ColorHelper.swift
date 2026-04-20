//
//  ColorHelper.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 20/04/26.
//

import Foundation
import SwiftUI

extension Color {
    func toData() -> Data? {
        let uiColor = UIColor(self)
        return try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
    }
}

extension Data {
    func toColor() -> Color? {
        guard let uiColor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(self) as? UIColor else { return nil }
        return Color(uiColor)
    }
}

let presetColors: [Color] = [
    .blue, .purple, .pink, .red, .orange, .yellow, .green, .mint, .teal, .indigo
]
