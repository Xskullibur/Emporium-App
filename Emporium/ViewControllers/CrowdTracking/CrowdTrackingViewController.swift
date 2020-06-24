//
//  CrowdTrackingViewController.swift
//  Emporium
//
//  Created by Riyfhx on 23/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//
import AVFoundation
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
//            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
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
//            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice?.activeFormat.formatDescription)!)
//            bufferSize.width = CGFloat(dimensions.width)
//            bufferSize.height = CGFloat(dimensions.height)
            videoDevice!.unlockForConfiguration()
        } catch {
            print(error)
            
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer)
        
        }
    }
    
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
