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
        Image(selectedFrame)
            .resizable()
            .scaledToFit()
            .scaleEffect(0.55)
    }
}

#Preview {
    StampOverlay(selectedFrame: "stamp_frame_1")
}
