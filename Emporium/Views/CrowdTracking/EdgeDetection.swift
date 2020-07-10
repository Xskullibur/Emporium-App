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
    
    //MARK: - Detection Rectangles
    private static let UNDETECTED_COLOR = UIColor.blue
    private static let DETECTED_COLOR = UIColor.red
    private static let DETECTION_MARGIN: CGFloat = 70.0
    
    private var topDetector: Detector!
    private var bottomDetector: Detector!
    private var leftDetector: Detector!
    private var rightDetector: Detector!
    
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
        
        //Create detection rectangles
        self.topDetector = Detector(rectangle: CGRect(x: 0, y: 0, width: previewView.frame.width, height: EdgeDetection.DETECTION_MARGIN))
        self.bottomDetector = Detector(rectangle: CGRect(x: 0, y: previewView.frame.height - EdgeDetection.DETECTION_MARGIN, width: previewView.frame.width, height: EdgeDetection.DETECTION_MARGIN))
        self.leftDetector = Detector(rectangle: CGRect(x: 0, y: 0, width: EdgeDetection.DETECTION_MARGIN, height: previewView.frame.height))
        self.rightDetector = Detector(rectangle: CGRect(x: previewView.frame.width - EdgeDetection.DETECTION_MARGIN, y: 0, width: EdgeDetection.DETECTION_MARGIN, height: previewView.frame.height))
        //Add detection rectangles to layer (visualise the detection bounds)
        self.drawDetectionRectangles()
        
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
        
        var newShapeLayers: [CALayer] = []
        var midPoints: [CGPoint] = []
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            
            // Only detect person
            guard topLabelObservation.identifier == "person" else{
                continue
            }
            
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            topLabelObservation.identifier,
                                                            topLabelObservation.confidence)
            
            //MARK: - Determine the direction of where the box is moving
            let midPoint = CGPoint(x: objectBounds.midX, y: objectBounds.midY)
            
            //Get the closest old shape layer
            var points = self.oldShapeLayers.map{ CGPoint(x: $0.frame.midX, y: $0.frame.midY)}.sorted(by: {$0.getEuclideanDistance(point: midPoint) < $1.getEuclideanDistance(point: midPoint)})
            let closestPoint = points.first

            if let closestPoint = closestPoint {
                // Get direction of the two points
                let theta = midPoint.getAngle(of: closestPoint)
                if (theta >= 0 && theta < 90) || (theta >= 270) {
                    shapeLayer.backgroundColor = UIColor.green.cgColor
                }else {
                    shapeLayer.backgroundColor = UIColor.orange.cgColor
                }
            }
            
            midPoints.append(midPoint)

            
            //shapeLayer.addSublayer(textLayer)
            //previewView.layer.insertSublayer(previewLayer, at: 0)
            //shapeLayer.frame = previewLayer.bounds
            //Clear sublayers
            
            //Add shape layer to preview layer for display
            newShapeLayers.append(shapeLayer)
            shapeLayer.addSublayer(textLayer)
            previewLayer.addSublayer(shapeLayer)
        }
        
        //Check detection bounds
        let side = self.checkDetectionForObservation(points: midPoints)
        if side != .none {
            self.delegate.onEdgeDetect(side: side)
        }
        
        //Updates the old shape layers to the new shape layers
        self.oldShapeLayers = newShapeLayers
        
        
        
    }
    
    /**
     Check if observation intersects with any detection rectangles
     */
    private func checkDetectionForObservation(points: [CGPoint]) -> Side{
        if self.topDetector.updatePoints(points) != 0{ return .top}
        else if self.bottomDetector.updatePoints(points) != 0 {return .bottom}
        else if self.leftDetector.updatePoints(points) != 0 {return .left}
        else if self.rightDetector.updatePoints(points) != 0 {return .right}
        return .none
    }
    
    /**
     Draw the detection rectangles on the preview layer 
     */
    private func drawDetectionRectangles(){
        let topLayer = self.createRoundedRectLayerWithBounds(self.topDetector.rectangle)
        topLayer.backgroundColor = EdgeDetection.UNDETECTED_COLOR.cgColor
        self.previewLayer.addSublayer(topLayer)
        
        let bottomLayer = self.createRoundedRectLayerWithBounds(self.bottomDetector.rectangle)
        bottomLayer.backgroundColor = EdgeDetection.UNDETECTED_COLOR.cgColor
        self.previewLayer.addSublayer(bottomLayer)
        
        let leftLayer = self.createRoundedRectLayerWithBounds(self.leftDetector.rectangle)
        leftLayer.backgroundColor = EdgeDetection.UNDETECTED_COLOR.cgColor
        self.previewLayer.addSublayer(leftLayer)
        
        let rightLayer = self.createRoundedRectLayerWithBounds(self.rightDetector.rectangle)
        rightLayer.backgroundColor = EdgeDetection.UNDETECTED_COLOR.cgColor
        self.previewLayer.addSublayer(rightLayer)
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
    func onEdgeDetect(side: Side)
}

enum Side {
    case top
    case bottom
    case left
    case right
    case none
}

class Detector {
    let rectangle: CGRect
    var trackingPoints: Set<CGPoint> = []
    
    private static let CLOSE_THRESHOLD = CGFloat(60.0) // How close should the points be to be considered as close
    
    init (rectangle: CGRect){
        self.rectangle = rectangle
    }
    
    /**
    Check for points which are contained inside the detector
     - Details:
         - New points which enter the detector will be added to the tracking list.
         - Points which exits from the detector will be removed from the tracking list.
     - Returns:
         - Number of points that has exited from the detector
     */
    func updatePoints(_ points: [CGPoint]) -> Int{
        
        var newTrackingPoints = Set<CGPoint>()
        var updatedOldTrackingPoints = Set<CGPoint>()
        
        for point in points {
            let contains = self.rectangle.contains(point)
            if contains {
                //Find any points which is close to this new point which intersects the detector
                let isCloseToAnyTrackingPoints = trackingPoints.contains(where: {self.isClose(point1: $0, point2: point)})
                
                if !isCloseToAnyTrackingPoints{
                    //If this new point is not close to any tracking points, means it is a new point.
                    
                    //Add this new point to the tracking list
                    newTrackingPoints.insert(point)
                }else{
                    //Probably some existing points that has moved.
                    
                    //Get the closest point from the old point
                    let closestTrackingPoint = trackingPoints.sorted(by: {$0.getEuclideanDistance(point: point) < $1.getEuclideanDistance(point: point)}).first!
                    
                    //Update the tracking point
                    updatedOldTrackingPoints.insert(closestTrackingPoint)
                    newTrackingPoints.insert(point)
                    
                }
                
            }
        }
        
        
        
        //Get exited points (points which does not appearing in the new tracking list)
        let exitedPoints = trackingPoints.subtracting(updatedOldTrackingPoints)
        
        //Update the old tracking list to the new tracking list
        self.trackingPoints = newTrackingPoints
        
        return exitedPoints.count
    }
    
    
    /**
     Check if two points are relatively close with each other
     */
    private func isClose(point1: CGPoint, point2: CGPoint) -> Bool{
        return point1.getEuclideanDistance(point: point2) <= Detector.CLOSE_THRESHOLD
    }
    
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

extension CGPoint : Hashable {
    /**
     Get the euclidean distance between this point and the second point.
     */
    func getEuclideanDistance(point: CGPoint) -> CGFloat{
        return sqrt(pow(self.x - point.x, 2) + pow(self.y - point.y, 2))
    }
    /**
     Get the polar angle between this point (origin) and the relative point.
     
     - Note:
        P1.getAngle(P2) != P2.getAngle(P1)
     
     - Parameters:
        point - Relative point from this point
     */
    func getAngle(of point: CGPoint) -> CGFloat {
        let x = point.x - self.x
        let y = self.y - point.y
        
        var offsetAngle = 0
        if x < 0{
            //Quadrant 2 or 3
            offsetAngle = 180
        }else if x >= 0 && y < 0  {
            //Quadrant 4
            offsetAngle = 360
        }
        
        let theta = toDegree(atan(y / x)) + CGFloat(offsetAngle)
        
        return theta
    }
    
    private func toDegree(_ rad: CGFloat) -> CGFloat{
        return rad * 180 / .pi
    }
    
    public var hashValue: Int {
        return x.hashValue ^ y.hashValue
    }
}
