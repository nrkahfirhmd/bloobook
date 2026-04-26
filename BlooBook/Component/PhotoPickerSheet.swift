//
//  PhotoPickerSheet.swift
//  BlooBook
//
//  Created by Muhammad Bintang Al-Fath on 21/04/26.
//

import SwiftUI
import SwiftData

struct PhotoPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    let memories: [Memory]
    @State private var selectedMemories: Set<Memory> = []
    @Bindable var album: Album
    @State private var rotations: [UUID: Double] = [:]
    var columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24){
                    ForEach(memories) { memory in
                        selectableCard(memory)
                    }
                }
                .padding()
            }
            .navigationTitle("Add Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction){
                    Button(role: .confirm){
                        savePhotos()
                        dismiss()
                    }label: {
                        Image(systemName: "checkmark")
                    }
                }
                ToolbarItem(placement: .cancellationAction){
                    Button(role: .cancel){
                        dismiss()
                    }label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
    
    func selectableCard(_ memory: Memory) -> some View {
        let rotation = rotations[memory.id] ?? 0
        
        return ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(data: memory.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .opacity(selectedMemories.contains(memory) ? 0.7 : 1)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
            }
            
            if selectedMemories.contains(memory) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .background {
                        Circle().fill(.primary)
                    }
                    .overlay {
                        Circle().stroke(Color.primary, lineWidth: 2)
                    }
                    .padding(12)
            }
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            if rotations[memory.id] == nil {
                rotations[memory.id] = Double.random(in: -5...5)
            }
        }
        .onTapGesture {
            toggle(memory)
        }
    }
    
    func toggle(_ memory: Memory){
        if selectedMemories.contains(memory) {
            selectedMemories.remove(memory)
        } else {
            selectedMemories.insert(memory)
        }
    }
    
    func savePhotos() {
        for memory in selectedMemories {
            
            let alreadyExists = album.photos.contains {
                $0.memory.id == memory.id
            }
            
            if !alreadyExists {
                let photo = Photo(
                    position: CGPoint(
                        x: CGFloat.random(in: 100...300),
                        y: CGFloat.random(in: 200...500)
                    ),
                    scale: 1,
                    rotation: Angle(degrees: 0),
                    memory: memory,
                    albums: [album]
                )
                
                context.insert(photo)
                album.photos.append(photo)
            }
        }
        selectedMemories.removeAll()
    }
}
