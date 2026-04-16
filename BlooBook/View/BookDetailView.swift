//
//  BookDetailView.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 16/04/26.
//

import SwiftUI

struct BookDetailView: View {
    var body: some View {
        NavigationStack {
            ZStack{
                Image(.paper1)
                
                Image(.batur)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 160)
                    .mask(
                        Image(.stampVertical)
                            .resizable()
                            .scaledToFit()
                        
                    )
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {

                    } label: {
                        Label("Image", systemImage: "photo")
                    }
                    
                    Button {
                        
                    } label: {
                        Label("Customize", systemImage: "paintpalette.fill")
                    }
                    
                    Spacer()
                   
                    Button {
                        
                    } label: {
                        Label("Stamp", systemImage: "plus")
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
            
            
            
        }
    }
}

#Preview {
    BookDetailView()
}
