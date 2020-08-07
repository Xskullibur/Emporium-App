//
//  InStoreViewController.swift
//  Emporium
//
//  Created by Xskullibur on 23/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import Lottie
import CoreBluetooth

class InStoreViewController: UIViewController {

    // MARK: - Variables
    var queueId: String?
    var store: GroceryStore?
    var centralManager: CBCentralManager?
    
    // MARK: - Outlets
    @IBOutlet weak var exitStoreBtn: MDCButton!
    @IBOutlet weak var requestorListBtn: MDCButton!
    @IBOutlet weak var animationView: AnimationView!
    
    // MARK: - IBActions
    @IBAction func exitBtnPressed(_ sender: Any) {
        
        showSpinner(onView: self.view)
        
        let queueDataManager = QueueDataManager()
        queueDataManager.updateQueue(queueId!, withStatus: .Completed, forStoreId: store!.id) { (success) in
            
            self.removeSpinner()
            
            if success {
                self.navigationController?.popToRootViewController(animated: true)
            }
            else {
                // Alert
                let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
                let data = Plist.readPlist(url!)!
                let infoDescription = data["Error Alert"] as! String
                self.showAlert(title: "Oops!", message: infoDescription)
            }
            
        }
    }
    
    @IBAction func requestorListBtnPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowRequestorList", sender: self)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Animation
        animationView.animation = Animation.named("shopping-bag")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        
        // Button
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = UIColor(named: "Primary")!
        
        exitStoreBtn.minimumSize = CGSize(width: 64, height: 48)
        exitStoreBtn.applyContainedTheme(withScheme: containerScheme)
        
        requestorListBtn.minimumSize = CGSize(width: 64, height: 48)
        requestorListBtn.applyOutlinedTheme(withScheme: containerScheme)
        
        // BLE
        centralManager = CBCentralManager()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        animationView.play()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowRequestorList" {
            let requestorListVC = segue.destination as! RequestorsListViewController
            requestorListVC.store = store!
            requestorListVC.queueId = queueId!
        }
        
    }

}

extension InStoreViewController: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state == .poweredOn {
            startScanning()
            print("Scanning...")
        }
        else if central.state == .poweredOff {
            centralManager!.stopScan()
        }
        else if central.state == .unsupported {
            self.showAlert(title: "Error", message: "This device is not supported for Scanning")
        }
        
    }
    
    func startScanning() {
        
        centralManager!.scanForPeripherals(withServices: nil, options: nil)
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        // Enter Store
        if advertisementData["EntryBeacon"] as! String == store!.id {
            
            // Show Local Notification
            let content = LocalNotificationHelper.createNotificationContent(title: "Goodbye", body: "Thank you for shopping with us", subtitle: nil, others: nil)
            LocalNotificationHelper.addNotification(identifier: "StoreEntry.notification", content: content)
            
            // Update Firestore
            exitBtnPressed(self)
            
        }
        
    }
    
}
