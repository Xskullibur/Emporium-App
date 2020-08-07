//
//  CrowdTrackingViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 23/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//
import AVFoundation
import CoreML
import Vision
import UIKit
import Combine
import MaterialComponents.MaterialCards
import CoreBluetooth
import CoreLocation

class CrowdTrackingViewController: UIViewController, EdgeDetectionDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var cardView: MDCCard!
    
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var noOfShopperLabel: UILabel!
    @IBOutlet weak var directionBtn: UIButton!
    
    @IBOutlet weak var previewViewHeightConstraint: NSLayoutConstraint!
    // MARK: - Variables
    private var cancellables: Set<AnyCancellable>? = Set<AnyCancellable>()
    private let visitorCountPublisher = PassthroughSubject<Int, Never>()
    private var diffVisitorValue = 0
    private var currentVisitorCount = 0
    
    private var edgeDetection: EdgeDetection!
    private var currentEdgeDetectionVisitorCount = 0
    private var direction: Direction = .leftToRight
    
    private var peripheralManager: CBPeripheralManager?
    private var beaconPeripheralData: [String: Any]?
    
    // MARK: - Firebase
    private var crowdTrackingDataManager: CrowdTrackingDataManager!
    
    var groceryStoreId: String? = nil
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // BLE
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        startAdvertisingDevice(nameKey: "EntryBeacon", uuid: groceryStoreId!)
        
        // User Interface
        /// CardView
        cardView.cornerRadius = 13
        cardView.clipsToBounds = true
        cardView.setBorderWidth(1, for: .normal)
        cardView.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
        cardView.layer.masksToBounds = false
        cardView.setShadowElevation(ShadowElevation(6), for: .normal)
        
        self.showSpinner(onView: self.view)
        
        /// Setup edge detection
        self.edgeDetection = EdgeDetection()
        let ableToSetupEdgeDetection = self.edgeDetection.setup(previewView: self.previewView, delegate: self)
        if ableToSetupEdgeDetection {
            self.showAlert(title: "Error", message: "No Camera detected!")
        }
        
        ///Setup data manager
        self.setupDataManager()
        
        self.visitorCountPublisher.debounce(for: .milliseconds(500), scheduler: RunLoop.main).eraseToAnyPublisher().sink{
            value in
            
            self.crowdTrackingDataManager.addVisitorCount(groceryStoreId: self.groceryStoreId!, value: self.diffVisitorValue, completion: nil)
            
            self.diffVisitorValue = 0
        }.store(in: &cancellables!)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        DispatchQueue.global(qos: .background).async {
            self.stopAdvertising()
        }
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


    func createBufferSize() -> CGSize {
        var bufferSize = CGSize()
        previewViewHeightConstraint.constant = self.view.frame.width * 0.5
        previewView.layoutIfNeeded()
        bufferSize.width = self.previewView.frame.width
        bufferSize.height = self.previewView.frame.height
        return bufferSize
    }
    
    func onEdgeDetect(side: Side) {
        switch side {
        case .left:
            print("Left")
            
            //Might overwrite the server updated value (dirty write)
            switch self.direction{
            case .leftToRight:
                self.changeVisitorValue(self.currentVisitorCount+1)
                break
            case .rightToLeft:
                self.changeVisitorValue(self.currentVisitorCount-1)
                break
            }
            
            
            break
        case .right:
            print("Right")
            
            //Might overwrite the server updated value (dirty write)
            switch self.direction{
            case .leftToRight:
                self.changeVisitorValue(self.currentVisitorCount-1)
                break
            case .rightToLeft:
                self.changeVisitorValue(self.currentVisitorCount+1)
                break
            }
            
            break
        default:
            break
        }
    }
    
    /**
        IBAction for stepper, use for manually controlling the amount of shopper inside the supermarket.
     */
    @IBAction func changeNoOfShoppersStepper(_ sender: Any) {
        let visitorValue = Int(self.stepper.value)
        self.changeVisitorValue(visitorValue)
    }
    
    private func changeVisitorValue(_ visitorValue: Int){
        self.diffVisitorValue = visitorValue - self.currentVisitorCount
        
        //Send arbitrary value to publisher (signaling only)
        self.visitorCountPublisher.send(0)
        
        self.noOfShopperLabel.text = String(visitorValue)

    }
    
    
    @IBAction func chooseDirectionPressed(_ sender: UIView) {
        let actionSheet = UIAlertController.init(title: "Direction", message: nil, preferredStyle: .actionSheet)
        
        let leftToRightButton = UIAlertAction.init(title: "Left to Right", style: .default, handler: {
            _ in
            self.direction = .leftToRight
            self.directionBtn.setTitle("Left to Right", for: .normal)
            
        })
        let rightToLeftButton = UIAlertAction.init(title: "Right to Left", style: .default, handler: {
            _ in
            self.direction = .rightToLeft
             self.directionBtn.setTitle("Right to Left", for: .normal)
        })
        
        actionSheet.addAction(leftToRightButton)
        actionSheet.addAction(rightToLeftButton)
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        self.present(actionSheet, animated: true, completion: nil)
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

// MARK: - CBPeripheral
extension CrowdTrackingViewController: CBPeripheralManagerDelegate {
    
    // MARK: -- Advertise
    func startAdvertisingDevice(nameKey: String, uuid: String) {
        peripheralManager!.startAdvertising([CBAdvertisementDataLocalNameKey : nameKey, CBAdvertisementDataServiceUUIDsKey : uuid])
        print("Advertising...")
    }
    
    // MARK: -- Stop Advertising
    func stopAdvertising() {
        peripheralManager!.stopAdvertising()
    }
    
    // MARK: -- Listener
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if peripheral.state == .poweredOn {
            peripheralManager!.startAdvertising(beaconPeripheralData)
            print("Advertising...")
        }
        else if peripheral.state == .poweredOff {
            peripheralManager!.stopAdvertising()
        }
        else if peripheral.state == .unsupported {
            self.showAlert(title: "Error", message: "This device is not supported for Advertising")
        }
        
    }
    
}
