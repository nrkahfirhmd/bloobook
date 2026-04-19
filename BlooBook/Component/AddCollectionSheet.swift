//
//  AddCollectionSheet.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 18/04/26.
//

import SwiftUI

struct AddCollectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    var body: some View {
        NavigationStack {
            
            Form {
                Section {
                    TextField("Collection Name", text: $name)
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        saveCollection()
                        dismiss()
                    } label: {
                        Text("Create")
                        
                    }
                    .buttonStyle(.glassProminent)
                }
                ToolbarItem {
                    
                   
                }
            }
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    
    func saveCollection() {
       
    
    }
}

#Preview {
    AddCollectionSheet()
}
