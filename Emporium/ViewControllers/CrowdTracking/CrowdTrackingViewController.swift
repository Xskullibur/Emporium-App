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
import MaterialComponents.MaterialCards

class CrowdTrackingViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var cardView: MDCCard!
    
    @IBOutlet weak var noOfShopperLabel: UILabel!
    
    // MARK: - Variables
    private let session = AVCaptureSession()
    private var deviceInput: AVCaptureDeviceInput!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var videoDataOutput: AVCaptureVideoDataOutput!
    
    private var bufferSize: CGSize!
    
    private var visionModel: VNCoreMLModel!
    
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
        
        ///Setup camera
        self.setupAVCapture()
        ///Setup model
        self.loadModel()
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
        
        //Add video output
        self.videoDataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            // Add a video data output
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            //videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
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
    
    private func loadModel(){
        let yoloModel = YOLOv3TinyFP16()
        do {
        visionModel = try VNCoreMLModel(for: yoloModel.model)
            
        let objectRecognition = VNCoreMLRequest(model: visionModel){
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
    
    private func drawVisionRequestResults(_ results: [Any]) {
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            // Select only the label with the highest confidence.
            let topLabelObservation = objectObservation.labels[0]
            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            
            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            
//            let textLayer = self.createTextSubLayerInBounds(objectBounds,
//                                                            identifier: topLabelObservation.identifier,
//                                                            confidence: topLabelObservation.confidence)
            //shapeLayer.addSublayer(textLayer)
            //previewView.layer.insertSublayer(previewLayer, at: 0)
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
    
//    private func createTextSubLayerInBounds(_ objectBounds: CGRect, _ identitifer: String, _ confidence: Float) -> CATextLayer {
//        let textLayer = CATextLayer()
//        textLayer.name = identitifer
//    }
    
    /**
        IBAction for stepper, use for manually controlling the amount of shopper inside the supermarket.
     */
    @IBAction func changeNoOfShoppersStepper(_ sender: Any) {
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
