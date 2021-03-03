//
//  FrameExtractor.swift

import UIKit
import AVFoundation
import CoreImage.CIFilterBuiltins

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage)
}

class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    private var frameCounter = 0;
    
    private let position = AVCaptureDevice.Position.front
    private let quality = AVCaptureSession.Preset.medium
    
    private var permissionGranted = false
    private let sessionQueue = DispatchQueue(label: "session queue")
    let captureSession = AVCaptureSession()
    
    private let context = CIContext()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    var imagePreviewView: UIImageView!
    
    weak var delegate: FrameExtractorDelegate?
    
    override init() {
        
        super.init()
        checkPermission()
        
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    // MARK: AVSession configuration
    private func checkPermission() {
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
    }
    
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    private func configureSession() {
        guard permissionGranted else {
            print("Error: No permissionGranted")
            return
        }
        captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else {
            print("Error: No captureDevice")
            return
        }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Error: No captureDeviceInput")
            return
        }
        guard captureSession.canAddInput(captureDeviceInput) else {
            print("Error: No captureSession")
            return
        }
        captureSession.addInput(captureDeviceInput)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard captureSession.canAddOutput(videoOutput) else {
            print("Error: No captureSession.canAddOutput")
            return
        }
        captureSession.addOutput(videoOutput)
        guard let connection = videoOutput.connection(with: AVFoundation.AVMediaType.video) else {
            print("Error: No videoOutput.connection")
            return
        }
        guard connection.isVideoOrientationSupported else {
            print("Error: No connection.isVideoOrientationSupported")
            return
        }
        guard connection.isVideoMirroringSupported else {
            print("Error: No connection.isVideoMirroringSupported")
            return
        }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = position == .front
    }
    
    private func selectCaptureDevice() -> AVCaptureDevice? {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            print("builtInWideAngleCamera")
            return device
        } else if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .front) {
            print("builtInDualCamera")
            return device
        } else {
            print("Error: No selectCaptureDevice (.video .front)")
            fatalError("Missing expected front camera device.")
        }
    }
    
    // MARK: Sample buffer to UIImage conversion
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> UIImage? {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        //print(imageBuffer)
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        let f = CIFilter.bicubicScaleTransform()
        f.inputImage = ciImage
        f.scale = 0.1
        guard let scaledImage = f.outputImage else { return nil }
        
        print(scaledImage)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        frameCounter += 1
        print("Frame captured \(frameCounter)")
        
        guard let uiImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.captured(image: uiImage)
        }
    }
    
    func displayPreview(on view: UIView) throws {
                
        let captureSession = self.captureSession
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
}
