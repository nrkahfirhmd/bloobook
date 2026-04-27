//
//  StampOverlay.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 16/04/26.
//

import SwiftUI

struct StampOverlay: View {
    var selectedFrame: String
    
    var body: some View {
        if selectedFrame.contains("polaroid") {
            Image(selectedFrame)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
        } else {
            Image(selectedFrame)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    StampOverlay(selectedFrame: "polaroid_frame_1")
}
