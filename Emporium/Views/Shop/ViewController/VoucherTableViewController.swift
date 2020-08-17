//
//  VoucherTableViewController.swift
//  Emporium
//
//  Created by user1 on 14/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Firebase
import Combine
import MaterialComponents.MaterialBottomSheet

class VoucherTableViewController: UITableViewController {

    // MARK: - Variables
    private var cancellables = Set<AnyCancellable>()
    
    private var myVouchers: [Voucher] = []
    private var voucherDataManager: VoucherDataManager? = nil
    
    var delegate: VoucherDelegate?
    
    private var user: User!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        Auth.auth().addStateDidChangeListener{
            (auth, user)  in
            self.user = user
            self.setupClaimedVouchers()
        }
        
    }
    

    /**
        Setup the claimed voucher DataManager
     */
    func setupClaimedVouchers(){
        guard user != nil else{
            return
        }
        
        self.voucherDataManager = VoucherDataManager(user: self.user)
           
           //Get available vouchers
        self.voucherDataManager?.getClaimedVoucher()!
               .sink(receiveCompletion: {
                   completion in
                   switch completion {
                   case .failure( _):
                    self.showAlert(title: "Error", message: "Error getting claimed vouchers")
                       print("Error getting claimed vouchers")
                       break;
                   case .finished:
                       break
                   }
               }, receiveValue: {
                   claimedVouchers in
                self.myVouchers = claimedVouchers.filter{!$0.used}
                   self.tableView.reloadData()
               }).store(in: &cancellables)
       }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.myVouchers.count > 0 {
            tableView.restore()
            return 1
        } else {
            tableView.setEmptyMessage("Oops no voucher to show here!")
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myVouchers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoucherCell", for: indexPath) as! MyVoucherTableViewCell
        
        cell.setVoucher(voucher: myVouchers[indexPath.row])
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        self.delegate?.setVoucher(voucher: myVouchers[indexPath.row])
        self.showAlert(title: "Success", message: "Voucher Added") {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: TESTING ONLY
    @IBAction func testAddPoints(_ sender: Any) {
        let functions = Functions.functions()
        functions.useFunctionsEmulator(origin: Global.FIREBASE_HOST)

        functions.httpsCallable("testAddPoints").call{
            _, _ in
        }
    }

}
