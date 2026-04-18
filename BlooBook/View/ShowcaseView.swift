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
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(memories) { memory in
                VStack {
                    Image(uiImage: memory.image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                    
                    Text(memory.title).bold()
                    
                    Text(memory.date, style: .date)
                        .font(Font.caption)
                        .foregroundColor(.secondary)
                }
                .onTapGesture {
                    selectedMemory = memory
                    
                    showDetailPopup.toggle()
                }
            }
        }
        .padding()
        .navigationTitle("Stamp")
        .sheet(isPresented: $showDetailPopup) {
            if let selectedMemory {
                DetailSheet(memory: selectedMemory)
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
