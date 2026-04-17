//
//  BookDetailView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI

struct BookDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State private var stamps: [StampModel] = []
    var body: some View {
        ZStack {
            Image(.paper1)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            if stamps.isEmpty {
                Text("Tap + to add stamp")
                    .foregroundStyle(.gray)
            }
            
            ForEach($stamps) { $stamp in
                DraggableStamp(stamp: $stamp)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    
                } label: {
                    Image(systemName: "photo")
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "paintpalette.fill")
                }
                
                Spacer()
                
                Button {
                    addStamp()
                } label: {
                    Image(systemName: "plus")
                }
                
                
                
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .navigationTitle("Book")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
    
    func addStamp() {
        let newStamp = StampModel(
            position: CGPoint(x: 200, y: 300),
            source: .batur,
            stamp: .stampVertical
        )
        
        stamps.append(newStamp)
    }
    
}

#Preview {
    BookDetailView()
}
