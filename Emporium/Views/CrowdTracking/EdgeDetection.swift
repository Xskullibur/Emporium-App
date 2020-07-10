//
//  EdgeDetection.swift
//  Emporium
//
//  Created by Peh Zi Heng on 10/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import Vision
import MLKit
import AVFoundation

class EdgeDetection: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Cameras
    private let session = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoDataOutput: AVCaptureVideoDataOutput!
    private var bufferSize: CGSize!
    
    // MARK: - AI Model
    private var visionModel: VNCoreMLModel!
    private var objectRecognition: VNRequest?
    
    // MARK: - Variables
    private var previewView: UIView!
    private var delegate: EdgeDetectionDelegate!
    
    // MARK: - Drawing Detection
    private var oldShapeLayers: [CALayer] = []
    
    /**
     Setup Edge Detection
     */
    func setup(previewView: UIView, delegate: EdgeDetectionDelegate){        
        self.previewView = previewView
        self.delegate = delegate
        
        ///Setup camera
        self.setupAVCapture()
        ///Setup model
        self.setupModel()
    }
    
    /**
     Setup model
     */
    private func setupModel(){
        let yoloModel = YOLOv3Tiny()
        do {
        visionModel = try VNCoreMLModel(for: yoloModel.model)
            
        self.objectRecognition = VNCoreMLRequest(model: visionModel){
            (request, error) in
            DispatchQueue.main.async {
                if let results = request.results {
                    self.delegate.onEdgeDetect(results)
                    self.drawVisionRequestResults(results)
                }
            }
        }
        }catch {
            print("Unable to create model")
        }
    }
    
    /**
     Setup the camera to start capturing
     */
    private func setupAVCapture(){
            let videoDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
            
            do {
                deviceInput = try AVCaptureDeviceInput(device: videoDevice!)
            }catch {
                print("Error creating video device! \(error)")
                return
            }
            
            session.beginConfiguration()
            session.sessionPreset = .vga640x480
            
            //Add video input
            guard session.canAddInput(deviceInput) else {
                print("Could not add video device input to the session")
                session.commitConfiguration()
                return
            }
            session.addInput(deviceInput)
            
            let videoDataOutputQueue = DispatchQueue(label: "videoDataOutputQueue")
            //Add video output
            self.videoDataOutput = AVCaptureVideoDataOutput()
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
                // Add a video data output
                videoDataOutput.alwaysDiscardsLateVideoFrames = true
                videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
                videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
            } else {
                print("Could not add video data output to the session")
                session.commitConfiguration()
                return
            }
            
            let captureConnection = videoDataOutput.connection(with: .video)
            // Always process the frames
            captureConnection?.isEnabled = true
            do {
                try  videoDevice!.lockForConfiguration()
                let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
                bufferSize = self.delegate.createBufferSize()
//    //            let ratio = self.previewView.frame.width / CGFloat(dimensions.width)
//    //            previewViewHeightConstraint.constant = CGFloat(dimensions.height) * ratio
//                previewViewHeightConstraint.constant = self.previewView.frame.width * 0.5
//                previewView.layoutIfNeeded()
//                bufferSize.width = self.previewView.frame.width
//                bufferSize.height = self.previewView.frame.height
                videoDevice!.unlockForConfiguration()
            } catch {
                print(error)
            }
            session.commitConfiguration()
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.frame = previewView.bounds
            previewView.layer.addSublayer(previewLayer)
            
            session.startRunning()
        }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        let pixelBuffer = sampleBuffer.imageBuffer!
        let exifOrientation = self.exifOrientationFromDeviceOrientation
        let imageRequestHandler = VNImageRequestHandler.init(cvPixelBuffer: pixelBuffer, orientation: CGImagePropertyOrientation(rawValue: CGImagePropertyOrientation.RawValue(exifOrientation))!, options: [:])
        
        do {
            if self.objectRecognition != nil{
                try imageRequestHandler.perform([objectRecognition!])
            }
        }catch {print(error)}
    }
    
    private func drawVisionRequestResults(_ results: [Any]) {
        self.oldShapeLayers.forEach {
            $0.removeFromSuperlayer()
        }
        self.oldShapeLayers.removeAll()
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            topLabelObservation.identifier,
                                                            topLabelObservation.confidence)
            //shapeLayer.addSublayer(textLayer)
            //previewView.layer.insertSublayer(previewLayer, at: 0)
            //shapeLayer.frame = previewLayer.bounds
            //Clear sublayers
            self.oldShapeLayers.append(shapeLayer)
            shapeLayer.addSublayer(textLayer)
            previewLayer.addSublayer(shapeLayer)
        }
    }
    
    var exifOrientationFromDeviceOrientation: Int32 {
        let exifOrientation: DeviceOrientation
        enum DeviceOrientation: Int32 {
            case top0ColLeft = 1
            case top0ColRight = 2
            case bottom0ColRight = 3
            case bottom0ColLeft = 4
            case left0ColTop = 5
            case right0ColTop = 6
            case right0ColBottom = 7
            case left0ColBottom = 8
        }
        switch UIDevice.current.orientation {
        case .portraitUpsideDown:
            exifOrientation = .left0ColBottom
        case .landscapeLeft:
            exifOrientation = .top0ColLeft
        case .landscapeRight:
            exifOrientation = .bottom0ColRight
        default:
            exifOrientation = .right0ColTop
        }
        return exifOrientation.rawValue
    }
    
}

protocol EdgeDetectionDelegate {
    func createBufferSize() -> CGSize
    func onEdgeDetect(_ results: [Any])
}

/**
 Create bounded rectangles/text
 */
extension EdgeDetection {
    private func createRoundedRectLayerWithBounds(_ objectBounds: CGRect)-> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = objectBounds
        shapeLayer.position = CGPoint(x: objectBounds.midX, y: objectBounds.midY)
        shapeLayer.name = "Detected Object"
        shapeLayer.backgroundColor = UIColor.yellow.cgColor
        return shapeLayer
        
    }
    
    private func createTextSubLayerInBounds(_ objectBounds: CGRect, _ identitifer: String, _ confidence: Float) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: "\(identitifer)\nConfidence: \(confidence)")
        let largeFont = UIFont.init(name: "Helvetica", size: 24.0)
        
        formattedString.addAttributes([
            .font: largeFont!
        
        ], range: NSRange(location: 0, length: identitifer.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0,y: 0,width: objectBounds.size.height - 10, height: objectBounds.size.width - 10)
        textLayer.position = CGPoint(x: objectBounds.midX, y: objectBounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = UIColor.yellow.cgColor
        
        
        return textLayer
    }
    
}
