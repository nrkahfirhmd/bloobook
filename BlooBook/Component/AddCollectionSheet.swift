//
//  AddCollectionSheet.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 18/04/26.
//

import SwiftUI
import SwiftData

struct AddCollectionSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    @State private var showAlbumPicker = false
    @State private var selectedAlbums: Set<Album> = []
    @State private var name = ""
    @State private var isDirectlyAdd: Bool = false
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Collection Name", text: $name)
                }
                Section {
                    Button {
                        showAlbumPicker = true
                    } label: {
                        Label("Add Albums", systemImage: "plus.circle")
                    }
                }
                if !selectedAlbums.isEmpty {
                    Section("Selected Albums") {
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(Array(selectedAlbums)) { album in
                                    AlbumCard(
                                        album: album
                                    )
                                    .frame(width: 140)
                                    .scrollTargetLayout()
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .scrollTargetBehavior(.viewAligned)
                        .scrollIndicators(.hidden)
                        .padding(.horizontal, -20)
                    }
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
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .sheet(isPresented: $showAlbumPicker) {
                AlbumPickerSheet(
                    selectedAlbums: $selectedAlbums
                )
            }
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
    func saveCollection() {
        let collection = Collection(
            name: name,
            albums: Array(selectedAlbums)
        )
        
        context.insert(collection)
    }
}

#Preview {
    AddCollectionSheet()
}
