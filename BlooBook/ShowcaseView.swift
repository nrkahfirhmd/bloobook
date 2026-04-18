//
//  ShowcaseView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 17/04/26.
//

import SwiftUI

struct ShowcaseView: View {
    var memories: [Memory] = []
    @State private var selectedMemory: Memory?
    @State private var showDetailPopup: Bool = false
    
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
                .onTapGesture {
                    selectedMemory = memory
                    
                    showDetailPopup.toggle()
                }
            }
        }
        .navigationTitle("Stamp")
        .sheet(isPresented: $showDetailPopup) {
            if let selectedMemory {
                DetailView(memory: selectedMemory)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            } else {
                Text("No memory selected")
            }
        }
    }
}

#Preview {
    ShowcaseView()
}
