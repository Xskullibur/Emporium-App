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
    
    private var trackingPoints = Set<TrackingPoint>() // Current list of tracking points
    private static let CLOSE_THRESHOLD = CGFloat(60.0) // How close should the points be to be considered as close
    
    // MARK: - Drawing Detection
    private var oldShapeLayers: [CALayer] = []
    
    //MARK: - Detection Rectangles
    private static let UNDETECTED_COLOR = UIColor.blue
    private static let DETECTED_COLOR = UIColor.red
    private static let DETECTION_MARGIN: CGFloat = 70.0
    
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
                    
                    //Get the new tracking points
                    let newTrackingPoints = self.getObservationObjects(from: results)
                        .map{
                            (observation) -> TrackingPoint in
                            //Transform observation into tracking point
                            let objectBounds = VNImageRectForNormalizedRect(observation.boundingBox, Int(self.bufferSize.width), Int(self.bufferSize.height))
                            
                            return TrackingPoint(objectBounds: objectBounds, observation: observation)
                    }
                    //Update the current tracking points
                    self.updateCurrentTrackingPoints(newTrackingPoints)
                    let updatedTrackingPoints = Array(self.trackingPoints)
                    
                    //Check if the tracking points have pass by the detector
                    let detectedSide = self.checkDetectionForObservation(trackingPoints: updatedTrackingPoints)
                    if detectedSide != .none {self.delegate.onEdgeDetect(side: detectedSide)}
                    
                    //Draw the tracking points
                    self.drawTrackingPoints(updatedTrackingPoints)
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
                try videoDevice!.lockForConfiguration()
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
    
    private func drawTrackingPoints(_ trackingPoints: [TrackingPoint]) {
        //Clear all the old shapes from the view
        self.oldShapeLayers.forEach {
            $0.removeFromSuperlayer()
        }
        
        var newShapeLayers: [CALayer] = []
        for trackingPoint in trackingPoints {
            
            let objectBounds = trackingPoint.rectangle
            
            // Select only the label with the highest confidence.
            let topLabelObservation = trackingPoint.observation.labels[0]
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            let textLayer = self.createTextSubLayerInBounds(objectBounds,
                                                            topLabelObservation.identifier,
                                                            topLabelObservation.confidence)
            
            //Change color of background based on direction
            if trackingPoint.side == .right {
                //Right direction
                shapeLayer.backgroundColor = UIColor.orange.cgColor
            }else if trackingPoint.side == .left{
                //Left direction
                shapeLayer.backgroundColor = UIColor.green.cgColor
            }
            
            //shapeLayer.addSublayer(textLayer)
            //previewView.layer.insertSublayer(previewLayer, at: 0)
            //shapeLayer.frame = previewLayer.bounds
            //Clear sublayers
            
            //Add shape layer to preview layer for display
            newShapeLayers.append(shapeLayer)
            shapeLayer.addSublayer(textLayer)
            previewLayer.addSublayer(shapeLayer)
        }
        
        //Updates the old shape layers to the new shape layers
        self.oldShapeLayers = newShapeLayers
    }
    
    /**
     Get observation objects from vision results
     */
    func getObservationObjects(from results: [Any]) -> [VNRecognizedObjectObservation]{
        var observations: [VNRecognizedObjectObservation] = []
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
            
            observations.append(objectObservation)
        }
        return observations
    }
    
    /**
     
    This functions updates the points which has moved based on the old tracking points.
     
    Tracks the point moving inside the viewport.
     
     - Details:
         - New points which enter the viewport will be added to the tracking list.
         - Points which moved will be updated with its new coordinates
         - Points which id not inside the viewport will be removed from the tracking list.
     */
    func updateCurrentTrackingPoints(_ newTrackingPoints: [TrackingPoint]){
        
        var updatedOldTrackingPoints = Set<TrackingPoint>()
        
        for newTrackingPoint in newTrackingPoints {
            //Get the middle point of the object bound
            let point = newTrackingPoint.point
            
            //Find any old tracking points which is close to this new point
            let isCloseToAnyTrackingPoints = trackingPoints.contains(where: {self.isClose(point1: $0.point, point2: point)})
            
            if !isCloseToAnyTrackingPoints{
                print("New Point")
                //If this new point is not close to any tracking points, means it is a new object bound.
                
                //Add this new tracking point to the tracking list
                trackingPoints.insert(newTrackingPoint)
                updatedOldTrackingPoints.insert(newTrackingPoint)
            }else{
                //Probably some existing object bound that has moved.
                
                //Get the closest point from the old point
                let closestTrackingPoint = trackingPoints.sorted(by: {
                    $0.point.getEuclideanDistance(point: point) < $1.point.getEuclideanDistance(point: point)
                    
                }).first!
                
                //Reset tracking point age
                closestTrackingPoint.age = TrackingPoint.MAX_AGE
                
                //Update the tracking point
                closestTrackingPoint.update(movedTrackingPoint: newTrackingPoint)
                updatedOldTrackingPoints.insert(closestTrackingPoint)
            }
        }
        
        //Remove all the tracking points that are not new or updated (the object is not detected anymore)
        let nonUpdatedTrackingPoints = trackingPoints.subtracting(updatedOldTrackingPoints)
        
        //Minus one age from the tracking point
        for nonUpdatedTrackingPoint in nonUpdatedTrackingPoints {
            nonUpdatedTrackingPoint.age -= 1
        }
        
        trackingPoints.subtract(nonUpdatedTrackingPoints.filter{$0.age <= 0})
        
    }
    /**
     Check if observation intersects with any detection rectangles
     */
    private func checkDetectionForObservation(trackingPoints: [TrackingPoint]) -> Side{
        if self.leftDetector.updateTrackingPoints(trackingPoints).contains(where: {$0.side == .left}) {return .left}
        else if self.rightDetector.updateTrackingPoints(trackingPoints).contains(where: {$0.side == .right}) {return .right}
        return .none
    }
    
    /**
     Draw the detection rectangles on the preview layer 
     */
    private func drawDetectionRectangles(){
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
        
    /**
     Check if two points are relatively close with each other
    */
    func isClose(point1: CGPoint, point2: CGPoint) -> Bool{
        return point1.getEuclideanDistance(point: point2) <= EdgeDetection.CLOSE_THRESHOLD
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
    var trackingPoints: Set<TrackingPoint> = [] // Tracking Points inside the detector
    
    init (rectangle: CGRect){
        self.rectangle = rectangle
    }
    
    /**
    Check for points which are contained inside the detector
     - Details:
         - New points which enter the detector will be added to the tracking list.
         - Points which exits from the detector will be removed from the tracking list.
     - Returns:
         - Tracking points that has exited from the detector
     */
    func updateTrackingPoints(_ trackingPoints: [TrackingPoint]) -> [TrackingPoint]{
        var updatedOldTrackingPoints = Set<TrackingPoint>()
        
        for trackingPoint in trackingPoints {
            let contains = self.rectangle.contains(trackingPoint.point)
            if contains {
                //Check if there is existing point
                if !self.trackingPoints.contains(trackingPoint){
                    //New point enter the detector
                    self.trackingPoints.insert(trackingPoint)
                    
                }
                updatedOldTrackingPoints.insert(trackingPoint)
            }
        }
        
        //Get exited points (points which does not appearing in the new tracking list)
        let exitedTrackingPoints = self.trackingPoints.subtracting(updatedOldTrackingPoints)
        self.trackingPoints.subtract(exitedTrackingPoints)
        
        return Array(exitedTrackingPoints)
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

class TrackingPoint : Hashable{
    var id: String
    var rectangle: CGRect
    var point: CGPoint {
        get {
            return CGPoint(x: rectangle.midX, y: rectangle.midY)
        }
    }
    var observation: VNRecognizedObjectObservation
    
    var age = MAX_AGE
    static var MAX_AGE = 3
    
    //Left is close to 0
    //Right is close to 1
    var direction: CGFloat = 0.5
    static var DIRECTION_UPDATE_RATE = 0.6
    
    var side: Side {
        get {
            if direction < 0.3 {
                return .left
            }else if direction > 0.7{
                return .right
            }else{
                return .none
            }
        }
    }
    
    init(objectBounds: CGRect, observation: VNRecognizedObjectObservation){
        self.rectangle = objectBounds
        self.observation = observation
        self.id = NSUUID().uuidString // Get a random uuid id
    }
    
    /**
     Update this tracking point with the new coorindates of the moved tracking point.
     
     NOTE:
     - id will still remain the same
     */
    func update(movedTrackingPoint newTrackingPoint: TrackingPoint){
        //MARK: - Determine the direction of where the box is moving

       // Get angle of the old tracking point and the new tracking point
       let theta = newTrackingPoint.point.getAngle(of: point)
       if (theta >= 0 && theta < 90) || (theta >= 270) {
           //Left direction
        self.direction += CGFloat(TrackingPoint.DIRECTION_UPDATE_RATE) * (0 - self.direction)
       }else {
            //Right direction
        self.direction += CGFloat(TrackingPoint.DIRECTION_UPDATE_RATE) * (1 - self.direction)
       }
        
        self.rectangle = newTrackingPoint.rectangle
        self.observation = newTrackingPoint.observation
        
       
        
    }
    
    
    static func == (lhs: TrackingPoint, rhs: TrackingPoint) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


extension CGPoint {
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
    
}
