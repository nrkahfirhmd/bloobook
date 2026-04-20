//
//  DetailView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 18/04/26.
//

import SwiftUI

struct DetailSheet: View {
    var memory = Memory(
        image: UIImage(named: "temp")!,
        title: "Da Vinci",
        note: "This photo I took while on a museum in Italy, I found some art interesting and opened a new perspective in me",
        date: Date()
    )
    
    var body: some View {
        VStack {
            HStack {
                Text(memory.title)
                    .bold()
                    .font(.title3)
                
                Spacer()
                
                Button(action: {} ) {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
            }
            
            Image(uiImage: memory.image)
                .resizable()
                .scaledToFit()
                .padding(.top)
            
            Text(memory.note)
                .italic()
            
            Text(memory.date, style: .date)
                .font(Font.caption)
                .foregroundColor(.secondary)
                .padding()
        }
        .padding()
    }
}

#Preview {
    DetailSheet()
}
