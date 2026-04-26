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
    @Bindable var textItem: CanvasText
    
    @State private var contentText: TextContent = TextContent(content: "")
    
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
                        
                        TextField("Rawr", text: $contentText.content)
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
            
            .navigationTitle("Add Text")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction){
                    Button(role: .confirm){
                        saveText()
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
}

#Preview {
    TextEditorSheet(album: Album(colorData: Data(), imageData: Data(), name: "", date: Date(), photos: [], stickers: [], texts: []),
                    textItem: CanvasText(text: TextContent(content: ""), position: CGPoint(x: 100, y: 100), scale: 1, rotation: Angle(degrees: 0), albums: []))
}
