//
//  CameraManager.swift
//  BlooBook
//
//  Created by Nurkahfi Rahmada on 16/04/26.
//

import AVFoundation
internal import Combine
import SwiftUI

class CameraManager: NSObject, ObservableObject {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    
    @Published var isFrontCamera = false
    @Published var capturedImage: UIImage?
    
    func setup() {
        session.beginConfiguration()
        
        guard let device = getCamera() else { return }
        let input = try! AVCaptureDeviceInput(device: device)
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
        session.startRunning()
    }
    
    func getCamera() -> AVCaptureDevice? {
        let position: AVCaptureDevice.Position = isFrontCamera ? .front : .back
        
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }
    
    func switchCamera() {
        isFrontCamera.toggle()
        session.inputs.forEach { session.isRunning ? session.removeInput($0) : () }
        setup()
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        output.capturePhoto(with: settings, delegate: self)
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}
