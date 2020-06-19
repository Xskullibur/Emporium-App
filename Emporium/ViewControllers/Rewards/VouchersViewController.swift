//
//  RewardsViewController.swift
//  Emporium
//
//  Created by Riyfhx on 18/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Combine
import Firebase
import MaterialComponents.MaterialBottomSheet

class VouchersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var vouchersTableView: UITableView!
    
    private var cancellables = Set<AnyCancellable>()
    private var vouchers: [Voucher] = []
    
    private var voucherDataManager: VoucherDataManager? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        vouchersTableView.dataSource = self
        vouchersTableView.delegate = self
        
        setupVouchers()
        
    }
    
    func setupVouchers(){
        self.voucherDataManager = VoucherDataManager(user: Auth.auth().currentUser)
        
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
                self.vouchersTableView.reloadData()
            }).store(in: &cancellables)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vouchers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VoucherCell", for: indexPath) as! VoucherTableViewCell
        
        cell.setVoucher(voucher: vouchers[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Show bottom sheet
        let storyboard = UIStoryboard.init(name: "Rewards", bundle: Bundle.init(for: VoucherBottomSheetViewController.self))
        let viewController = storyboard.instantiateViewController(identifier: "VoucherBottomSheetViewControllerID") as VoucherBottomSheetViewController
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        
        bottomSheet.preferredContentSize = CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height / 3)
        
        viewController.setVoucher(voucher: vouchers[indexPath.row])
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
