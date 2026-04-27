//
//  TextEditorSheet.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 24/04/26.
//

import SwiftUI
import SwiftData

struct TextEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var context
    
    @Bindable var album: Album
    var textItem: CanvasText?
    
    @State private var contentText: TextContent = TextContent(content: "")
    
    var isEditing: Bool { textItem != nil }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        HStack(spacing: 2) {
                            Text("Enter text")
                                .font(.title3)
                                .fontWeight(.medium)
                            
                            Text("*")
                                .foregroundStyle(Color.red)
                        }
                        
                        TextField("Add your text here...", text: $contentText.content, axis: .vertical)
                            .lineLimit(3...6)
                            .padding(16)
                            .background(.regularMaterial)
                            .cornerRadius(20)
                    }
                    
                    Picker("Font", selection: $contentText.fontName) {
                        Text("Helvetica").tag("Helvetica")
                        Text("Georgia").tag("Georiga")
                        Text("Courier").tag("Courier")
                        Text("Avenir").tag("Avenir")
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Size", selection: $contentText.fontSize) {
                        Text("Small").tag(18.0)
                        Text("Medium").tag(24.0)
                        Text("Large").tag(32.0)
                        Text("XL").tag(40.0)
                    }
                    .pickerStyle(.segmented)
                    
                    Toggle("Bold", isOn: $contentText.isBold)
                    
                    Toggle("Italic", isOn: $contentText.isItalic)
                }
                .padding()
            }
            
            .navigationTitle(isEditing ? "Edit Text" : "Add Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        isEditing ? updateText() : saveText()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .onAppear {
            if let existing = textItem {
                contentText = TextContent(
                    content: existing.text.content,
                    fontName: existing.text.fontName,
                    fontSize: existing.text.fontSize,
                    isBold: existing.text.isBold,
                    isItalic: existing.text.isItalic
                )
            }
        }
    }
    
    func saveText() {
        let text = CanvasText(
            text: contentText,
            position: CGPoint(
                x: CGFloat.random(in: 100...300),
                y: CGFloat.random(in: 200...500)
            ),
            scale: 1,
            rotation: Angle(degrees: 0),
            albums: [album]
        )
        
        context.insert(text)
        album.texts.append(text)
    }
    
    func updateText() {
        guard let item = textItem else { return }
        item.text.content  = contentText.content
        item.text.fontName = contentText.fontName
        item.text.fontSize = contentText.fontSize
        item.text.isBold   = contentText.isBold
        item.text.isItalic = contentText.isItalic
    }
}

#Preview {
    TextEditorSheet(album: Album(colorData: Data(), imageData: Data(), name: "", date: Date(), photos: [], stickers: [], texts: []),
                    textItem: CanvasText(text: TextContent(content: ""), position: CGPoint(x: 100, y: 100), scale: 1, rotation: Angle(degrees: 0), albums: []))
}
