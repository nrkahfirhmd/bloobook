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
    @Binding var draggingTextID: UUID?
    @Binding var isDragging: Bool
    @Binding var isOverTrash: Bool
    @Binding var trashFrame: CGRect
    
    @State private var trashScaleEffect: CGFloat = 1
    @State private var lastPosition: CGPoint = .zero
    @State private var lastScale: CGFloat = 1
    @State private var lastRotation: Double = 0
    @State private var currentPosition: CGPoint = .zero
    @State private var currentScale: CGFloat = 1
    @State private var currentRotation: Angle = .zero
    
    @Binding var selectedText: CanvasText?
    
    var backgroundImage: ImageResource
    
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
                .foregroundColor(backgroundImage == .paper3 ? .white : .black)
                .onTapGesture {
                    selectedText = textItem
                }
        }
        .rotationEffect(currentRotation)
        .scaleEffect(currentScale * trashScaleEffect)
        .position(currentPosition)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: trashScaleEffect)
        .onAppear {
            syncFromModel()
        }
        .onChange(of: textItem.posX) { _, _ in
            if draggingTextID != textItem.id {
                syncFromModel()
            }
        }
        .onChange(of: textItem.posY) { _, _ in
            if draggingTextID != textItem.id {
                syncFromModel()
            }
        }
        .onChange(of: textItem.scale) { _, _ in
            if draggingTextID != textItem.id {
                syncFromModel()
            }
        }
        .onChange(of: textItem.rotation) { _, _ in
            if draggingTextID != textItem.id {
                syncFromModel()
            }
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
                if draggingTextID != textItem.id {
                    draggingTextID = textItem.id
                }
                if !isDragging {
                    isDragging = true
                }
                
                let dragValue = value.first?.first
                let scaleValue = value.first?.second
                let rotationValue = value.second
                
                if let dragValue {
                    let t = dragValue.translation
                    let damping = 1 / sqrt(max(textItem.scale, 0.5))

                    currentPosition = CGPoint(
                        x: lastPosition.x + t.width * damping,
                        y: lastPosition.y + t.height * damping
                    )
                    
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
                        currentPosition.x += (trashFrame.midX - currentPosition.x - 100) * lerp
                        currentPosition.y += (trashFrame.midY - currentPosition.y - 100) * lerp
                    }
                }
                
                if let scaleValue {
                    let newScale = lastScale * scaleValue
                    currentScale = min(max(newScale, 0.75), 3.0)
                }
                
                if let rotationValue {
                    currentRotation = Angle(radians: lastRotation + rotationValue.radians)
                }
            }
            .onEnded { _ in
                if isOverTrash {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                        currentPosition = CGPoint(x: trashFrame.midX, y: trashFrame.midY)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        deleteText()
                    }
                } else {
                    textItem.posX = currentPosition.x
                    textItem.posY = currentPosition.y
                    textItem.scale = currentScale
                    textItem.rotation = currentRotation.radians
                }
                
                trashScaleEffect = 1
                isDragging = false
                isOverTrash = false
                draggingTextID = nil
                
                lastPosition = currentPosition
                lastScale = currentScale
                lastRotation = currentRotation.radians
            }
    }
    
    func deleteText() {
        context.delete(textItem)
    }

    private func syncFromModel() {
        let position = textItem.position
        let scale = textItem.scaleCGFloat
        let rotation = textItem.rotationAngle

        lastPosition = position
        lastScale = scale
        lastRotation = rotation.radians
        currentPosition = position
        currentScale = scale
        currentRotation = rotation
    }
}
