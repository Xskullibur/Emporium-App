//
//  VoucherBottomSheetViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 18/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialButtons

class VoucherBottomSheetViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var voucherNameLabel: UILabel!
    @IBOutlet weak var voucherDescriptionLabel: UILabel!
    @IBOutlet weak var claimButton: MDCButton!
    
    // MARK: - Variables
    private var voucher: Voucher?
    
    private var voucherDataManager: VoucherDataManager? = nil
    
    private var viewController: UIViewController? = nil
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.updateVoucher()
    }
    
    /**
     Set the voucher to be displayed
     */
    func setVoucher(voucher: Voucher){
        self.voucher = voucher
    }
    
    /**
     Update the view to display the voucher
     */
    private func updateVoucher(){
        self.voucherNameLabel.text = self.voucher?.name
        self.claimButton.setTitle("Claim (\(self.voucher!.cost) Points)", for: .normal)
        self.voucherDescriptionLabel.text = self.voucher?.description
    }
    
    /**
     Set the voucher Data Manager
        Note: Setting the DataManager is much memory friendly than creating new Data Manager
     */
    func setVoucherDataManager(dataManager: VoucherDataManager){
        self.voucherDataManager = dataManager
    }
    
    /**
     Set the view controller to be use for showing spinner
     */
    func setViewController(viewController: UIViewController){
        self.viewController = viewController
    }
    
    /**
     Set voucher to be claimed after pressed the claim button
     */
    @IBAction func claimPressed(_ sender: Any) {
        self.viewController?.showSpinner(onView: self.viewController!.view)
        self.voucherDataManager?.setClaimVoucher(voucher: self.voucher!){
            status in
            switch status {
            case .success:
                Toast.showToast("Voucher claimed!")
                break
            case .notEnoughPoints:
                Toast.showToast("Not enough points to claim this voucher!")
                break
            default:
                self.viewController?.showAlert(title: "Error", message: "Unable to claim the vouchers.")
                break
            }
        self.viewController?.removeSpinner()        }
        self.dismiss(animated: true)
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
