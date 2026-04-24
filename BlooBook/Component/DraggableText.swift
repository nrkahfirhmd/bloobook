//
//  CanvasTextWrapper.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 24/04/26.
//

import SwiftUI
import SwiftData

struct DraggableText: View {
    @Environment(\.modelContext) private var context
    
    @Bindable var textItem: CanvasText
    @Binding var draggingText: CanvasText?
    @Binding var isDragging: Bool
    @Binding var isOverTrash: Bool
    @Binding var trashFrame: CGRect
    
    @State private var trashScaleEffect: CGFloat = 1
    @State private var lastPosition: CGPoint = .zero
    @State private var lastScale: CGFloat = 1
    @State private var lastRotation: Double = 0
    
    var fontSettings: Font {
        let base = Font.custom(textItem.text.fontName, size: textItem.text.fontSize)
        
        if textItem.text.isBold && textItem.text.isItalic {
            return base.bold().italic()
        } else if textItem.text.isBold {
            return base.bold()
        } else if textItem.text.isItalic {
            return base.italic()
        }
        
        return base
    }
    
    var body: some View {
        Group {
            Text(textItem.text.content)
                .font(fontSettings)
        }
        .position(textItem.position)
        .rotationEffect(textItem.rotationAngle)
        .scaleEffect(textItem.scale * trashScaleEffect)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trashScaleEffect)
        .onAppear {
            lastPosition = textItem.position
            lastScale = textItem.scale
            lastRotation = textItem.rotation
        }
        .gesture(combinedGesture)
    }
    
    var combinedGesture: some Gesture {
        let drag = DragGesture()
        let scale = MagnificationGesture()
        let rotate = RotationGesture()
        
        return drag
            .simultaneously(with: scale)
            .simultaneously(with: rotate)
            .onChanged { value in
                
                draggingText = textItem
                isDragging = true
                
                let dragValue = value.first?.first
                let scaleValue = value.first?.second
                let rotationValue = value.second
                
                if let dragValue {
                    let t = dragValue.translation
                    let angle = lastRotation
                    
                    let adjustedX = t.width * cos(angle) + t.height * sin(angle)
                    let adjustedY = -t.width * sin(angle) + t.height * cos(angle)
                    
                    let damping = 1 / sqrt(max(textItem.scale, 0.5))
                    
                    textItem.posX = lastPosition.x + adjustedX * damping
                    textItem.posY = lastPosition.y + adjustedY * damping
                    
                    let touchPoint = dragValue.location
                    let expandedTrash = trashFrame.insetBy(dx: -20, dy: -150)
                    
                    let newIsOverTrash = expandedTrash.contains(touchPoint)
                    
                    if newIsOverTrash != isOverTrash {
                        isOverTrash = newIsOverTrash
                        
                        if isOverTrash {
                            let targetScale: CGFloat = 0.5
                            trashScaleEffect = targetScale / max(textItem.scale, 0.5)
                            
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        } else {
                            trashScaleEffect = 1
                        }
                    }
                    
                    if isOverTrash {
                        let lerp: CGFloat = 0.2
                        textItem.posX += (trashFrame.midX - textItem.posX - 100) * lerp
                        textItem.posY += (trashFrame.midY - textItem.posY - 100) * lerp
                    }
                }
                
                if let scaleValue {
                    let newScale = lastScale * scaleValue
                    textItem.scale = min(max(newScale, 0.75), 3.0)
                }
                
                if let rotationValue {
                    textItem.rotation = lastRotation + rotationValue.radians
                }
            }
            .onEnded { _ in
                
                if isOverTrash {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        textItem.posX = trashFrame.midX
                        textItem.posY = trashFrame.midY
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        deleteText()
                    }
                }
                
                trashScaleEffect = 1
                isDragging = false
                isOverTrash = false
                draggingText = nil
                
                lastPosition = textItem.position
                lastScale = textItem.scale
                lastRotation = textItem.rotation
            }
    }
    
    func deleteText() {
        context.delete(textItem)
    }
}
