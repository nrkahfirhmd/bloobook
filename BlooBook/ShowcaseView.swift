//
//  ShowcaseView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 17/04/26.
//

import SwiftUI

struct ShowcaseView: View {
    var memories: [Memory] = []
    
    var body: some View {
        NavigationStack {
            ForEach(memories) { memory in
                VStack {
                    Image(uiImage: memory.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                    
                    Text(memory.title).bold()
                }
            }
        }
        .navigationTitle(Text("Stamp"))
    }
}

#Preview {
    ShowcaseView()
}
