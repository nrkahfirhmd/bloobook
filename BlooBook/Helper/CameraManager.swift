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
    
    private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    
    @Published var isFrontCamera = false
    @Published var capturedImage: UIImage?
    
    func setup() {
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    private func configureSession() {
        session.beginConfiguration()
        
        session.inputs.forEach { session.removeInput($0) }
        
        guard let device = getCamera(),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input)
        else { return }
        
        session.addInput(input)
        
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
        
        sessionQueue.async {
            self.session.beginConfiguration()
            
            self.session.inputs.forEach { self.session.removeInput($0) }
            
            if let device = self.getCamera(),
               let input = try? AVCaptureDeviceInput(device: device),
               self.session.canAddInput(input) {
                self.session.addInput(input)
            }
        }
        
        session.commitConfiguration()
    }
    
    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
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
