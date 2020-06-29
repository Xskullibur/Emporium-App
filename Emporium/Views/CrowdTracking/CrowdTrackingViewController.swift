//
//  CrowdTrackingViewController.swift
//  Emporium
//
//  Created by Riyfhx on 23/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//
import AVFoundation
import CoreML
import Vision
import UIKit
import Combine
import MaterialComponents.MaterialCards

class CrowdTrackingViewController: UIViewController,
AVCaptureVideoDataOutputSampleBufferDelegate {

    // MARK: - Outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var cardView: MDCCard!
    
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var noOfShopperLabel: UILabel!
    
    // MARK: - Variables
    private var cancellables: Set<AnyCancellable>? = Set<AnyCancellable>()
    private let visitorCountPublisher = PassthroughSubject<Int, Never>()
    private var diffVisitorValue = 0
    private var currentVisitorCount = 0
    
    
    // MARK: - Cameras
    private let session = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoDataOutput: AVCaptureVideoDataOutput!
    private var bufferSize: CGSize!
    
    // MARK: - AI Model
    private var visionModel: VNCoreMLModel!
    private var objectRecognition: VNRequest?
    
    // MARK: - Drawing Detection
    private var oldShapeLayers: [CALayer] = []
    
    // MARK: - Firebase
    private var crowdTrackingDataManager: CrowdTrackingDataManager!
    
    var groceryStoreId: String? = "4b15f661f964a52012b623e3"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // User Interface
        /// CardView
        cardView.cornerRadius = 13
        cardView.clipsToBounds = true
        cardView.setBorderWidth(1, for: .normal)
        cardView.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
        cardView.layer.masksToBounds = false
        cardView.setShadowElevation(ShadowElevation(6), for: .normal)
        
        self.showSpinner(onView: self.view)
//        ///Setup camera
//        self.setupAVCapture()
//        ///Setup model
//        self.setupModel()
        
        ///Setup data manager
        self.setupDataManager()
        
        self.visitorCountPublisher.debounce(for: .milliseconds(500), scheduler: RunLoop.main).eraseToAnyPublisher().sink{
            value in
            
            self.crowdTrackingDataManager.addVisitorCount(groceryStoreId: self.groceryStoreId!, value: self.diffVisitorValue, completion: nil)
            
            self.diffVisitorValue = 0
        }.store(in: &cancellables!)
        
    }
    
    private func setupDataManager(){
        self.crowdTrackingDataManager = CrowdTrackingDataManager()
        
        //Setup stepper
        self.stepper.minimumValue = 0
        self.crowdTrackingDataManager.getGroceryStore(groceryStoreId: self.groceryStoreId!){
            groceryStore, error in
            
            if let groceryStore = groceryStore {
                self.stepper.maximumValue = Double(groceryStore.maxVisitorCapacity)
                self.stepper.value = Double(groceryStore.currentVisitorCount)
                
                self.noOfShopperLabel.text = String(groceryStore.currentVisitorCount)
                
                self.currentVisitorCount = groceryStore.currentVisitorCount
                
            }
            self.removeSpinner()
        }
    }
    
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
            bufferSize = CGSize()
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = previewView.bounds
        previewView.layer.insertSublayer(previewLayer, at: 0)
        
        session.startRunning()
    }
    
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
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection){
        let pixelBuffer = sampleBuffer.imageBuffer!
        var exifOrientation = self.exifOrientationFromDeviceOrientation
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
    
    /**
        IBAction for stepper, use for manually controlling the amount of shopper inside the supermarket.
     */
    @IBAction func changeNoOfShoppersStepper(_ sender: Any) {
        let visitorValue = Int(self.stepper.value)
        self.diffVisitorValue = visitorValue - self.currentVisitorCount
        
        //Send arbitrary value to publisher (signaling only)
        self.visitorCountPublisher.send(0)
        
        self.noOfShopperLabel.text = String(visitorValue)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
