//
//  RewardsViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 18/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Combine
import Firebase
import MaterialComponents

class VouchersViewController: UITableViewController {
    
    // MARK: - Variables
    private var cancellables = Set<AnyCancellable>()
    private var vouchers: [Voucher] = []
    
    private var voucherDataManager: VoucherDataManager? = nil
    
    private var user: User? = nil
    
    private var authListener: AuthStateDidChangeListenerHandle!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.authListener = Auth.auth().addStateDidChangeListener{
            (auth, user)  in
            self.user = user
            self.setupVouchers()
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(self.authListener)
    }
    
    /**
     Setup the Voucher Data Manager
     */
    func setupVouchers(){
        self.voucherDataManager = VoucherDataManager(user: self.user)
        
        //Get available vouchers
        self.voucherDataManager?.getAvailableVouchers()
            .sink(receiveCompletion: {
                completion in
                switch completion {
                    case .failure(let error):
                    print("Error getting available vouchers")
                    break;
                case .finished:
                    break
                }
            }, receiveValue: {
                availableVouchers in
                self.vouchers = availableVouchers
                self.tableView.reloadData()
            }).store(in: &cancellables)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vouchers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoucherCell", for: indexPath) as! VoucherTableViewCell
        
        cell.setVoucher(voucher: vouchers[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Show bottom sheet
        let storyboard = UIStoryboard.init(name: "Rewards", bundle: Bundle.init(for: VoucherBottomSheetViewController.self))
        let viewController = storyboard.instantiateViewController(identifier: "VoucherBottomSheetViewControllerID") as VoucherBottomSheetViewController
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        
        let screenRect = UIScreen.main.bounds
        
        bottomSheet.preferredContentSize = CGSize(width: screenRect.size.width, height: screenRect.size.height / 3)
        
        viewController.setVoucher(voucher: vouchers[indexPath.row])
        viewController.setViewForSpinner(view: self.view.superview!.superview!)
        viewController.setVoucherDataManager(dataManager: self.voucherDataManager!)
        self.present(bottomSheet, animated: true, completion: nil)
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
