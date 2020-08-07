//
//  ConfirmationViewController.swift
//  Emporium
//
//  Created by Xskullibur on 16/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import AVFoundation
import MapKit
import MaterialComponents.MaterialBottomSheet

class ConfirmationViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Variables
    var queueId: String?
    var store: GroceryStore?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: - IBActions
    @IBAction func infoBtnPressed(_ sender: Any) {
        
        //Show point info
        let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
        let data = Plist.readPlist(url!)!
        let infoDescription = data["Confirm Delivery Description"] as! String
        self.showAlert(title: "Info", message: infoDescription)
        
    }
    
    @IBAction func directionBtnPressed(_ sender: Any) {
        let annotation = StoreAnnotation(
            coords: CLLocationCoordinate2D(
                latitude: store!.location.latitude,
                longitude: store!.location.longitude
            ),
            store: store!
        )
        annotation.title = store!.name
        annotation.subtitle = store!.address
        
        // Show Directions
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDefault
        ]
        
        annotation.mapItem?.openInMaps(launchOptions: launchOptions)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Capture Session / Device
        self.view.backgroundColor = .black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            showNotSupportedAlert()
            return
        }
        
        // Setup Video Input
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        }
        catch {
            showNotSupportedAlert()
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        else {
            showNotSupportedAlert()
            return
        }
        
        // Setup Output
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
        else {
            showNotSupportedAlert()
            return
        }
        
        // Present Preview Layer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if captureSession.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning == true {
            DispatchQueue.global(qos: .background).async {
                self.captureSession.stopRunning()
            }
        }
        
    }
    
    // AVCapture
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            
            // Verify Contents / Outputs
            guard let readableObj = metadataObject as? AVMetadataMachineReadableCodeObject else {
                showErrorAlert()
                captureSession.startRunning()
                return
            }
            
            guard let stringVal = readableObj.stringValue else {
                showErrorAlert()
                captureSession.startRunning()
                return
            }
            
            // Play Vibration to alert user
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Verify and update server
            let deliveryDataManager = DeliveryDataManager()
            deliveryDataManager.verifyAndCompleteDelivery(deliveryId: stringVal, onComplete:{ (success) in
                
                if success {
                    // Show alert and navigate
                    self.showAlert(title: "Success", message: nil) {
                        
                        // Navigate
                        let completeVC = CompletedViewController()
                        let rootVC = self.navigationController?.viewControllers.first
                        self.navigationController?.setViewControllers([rootVC!, completeVC], animated: true)
                        
                    }
                }
                else {
                    self.showNotSupportedAlert()
                }
                
            }) { (error) in
                print("\(error)")
                self.showErrorAlert()
            }
            
        }
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: - Error Alert
    func showErrorAlert() {
        self.showAlert(title: "Oops", message: "Something went wrong. Please try scanning again.")
    }
    
    // MARK: - Not Supported Alert
    func showNotSupportedAlert() {
        self.showAlert(title: "Oops", message: "This device does not support this feature")
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showCompleteVC" {
            
            let completeVC = segue.destination
            let rootVC = self.navigationController?.viewControllers.first
            self.navigationController?.setViewControllers([rootVC!, completeVC], animated: true)
            
        }
        
    }
}
