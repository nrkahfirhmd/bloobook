//
//  DetailView.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 18/04/26.
//

import SwiftUI
import SwiftData

struct DetailSheet: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var memory = Memory(
        image: UIImage(named: "temp")!,
        title: "Da Vinci",
        note: "This photo I took while on a museum in Italy, I found some art interesting and opened a new perspective in me",
        date: Date(),
        stamp: "stamp_1"
    )
    
    @State private var showDeleteConfirm = false
    @State private var showEditSheet = false
    @State private var selectedStamp: String = ""
    var onDelete: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            HStack {
                Text(memory.title)
                    .bold()
                    .font(.title3)
                
                Spacer()
                
                HStack {
                    Button(action: { showDeleteConfirm = true } ) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .confirmationDialog("Are you sure you want to delete this memory?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            deleteMemory()
                        }
                    }
                    
                    Button(action: {
                        selectedStamp = memory.stamp
                        showEditSheet = true
                    } ) {
                        Image(systemName: "pencil.and.outline")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            
            if let uiImage = UIImage(data: memory.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(.top)
            }
            
            Text(memory.note)
                .italic()
            
            Text(memory.date, style: .date)
                .font(Font.caption)
                .foregroundColor(.secondary)
                .padding()
        }
        .padding()
        .sheet(isPresented: $showEditSheet) {
            SavePopupSheet(stamp: $selectedStamp, showSavePopup: $showEditSheet, mode: .edit, existingMemory: memory)
        }
    }
    
    func deleteMemory() {
        onDelete?()
        dismiss()

        DispatchQueue.main.async {
            withAnimation {
                context.delete(memory)
            }
        }
    }
}

#Preview {
    DetailSheet()
}
