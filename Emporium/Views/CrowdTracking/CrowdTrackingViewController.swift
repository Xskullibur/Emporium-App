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

class CrowdTrackingViewController: UIViewController, EdgeDetectionDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var cardView: MDCCard!
    
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var noOfShopperLabel: UILabel!
    
    @IBOutlet weak var previewViewHeightConstraint: NSLayoutConstraint!
    // MARK: - Variables
    private var cancellables: Set<AnyCancellable>? = Set<AnyCancellable>()
    private let visitorCountPublisher = PassthroughSubject<Int, Never>()
    private var diffVisitorValue = 0
    private var currentVisitorCount = 0
    
    private var edgeDetection: EdgeDetection!
    
    // MARK: - Firebase
    private var crowdTrackingDataManager: CrowdTrackingDataManager!
    
    var groceryStoreId: String? = nil
    
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
        
        /// Setup edge detection
        self.edgeDetection = EdgeDetection()
        self.edgeDetection.setup(previewView: self.previewView, delegate: self)
        
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


    func createBufferSize() -> CGSize {
        var bufferSize = CGSize()
        previewViewHeightConstraint.constant = self.previewView.frame.width * 0.5
        previewView.layoutIfNeeded()
        bufferSize.width = self.previewView.frame.width
        bufferSize.height = self.previewView.frame.height
        return bufferSize
    }
    
    func onEdgeDetect(side: Side) {
        switch side {
        case .left:
            print("Left")
            break
        case .right:
            print("Right")
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
        self.diffVisitorValue = visitorValue - self.currentVisitorCount
        
        //Send arbitrary value to publisher (signaling only)
        self.visitorCountPublisher.send(0)
        
        self.noOfShopperLabel.text = String(visitorValue)
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
