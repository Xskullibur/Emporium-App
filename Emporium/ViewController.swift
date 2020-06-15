//
//  ViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 19/5/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Combine
import MaterialComponents.MaterialCards

class ViewController: EmporiumNotificationViewController,
UICollectionViewDataSource, UICollectionViewDelegate {
    

    @IBOutlet weak var notificationTableView: UITableView!
    @IBOutlet weak var mainButtonsCollectionView: UICollectionView!
    
    let cells = ["CrowdTrackingCell", "ShopCell", "RewardsCell"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tableView = notificationTableView
        
        setupUI()
//        
        mainButtonsCollectionView.dataSource = self
        mainButtonsCollectionView.delegate = self
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = mainButtonsCollectionView.dequeueReusableCell(withReuseIdentifier: cells[indexPath.item], for: indexPath) as! MDCCardCollectionCell

        cell.contentView.layer.cornerRadius = 8
        cell.contentView.layer.masksToBounds = true
        cell.layer.masksToBounds = false
        cell.setShadowElevation(ShadowElevation(2), for: .normal)
        
        return cell
    }
    
    
    func setupUI(){
//        crowdTrackingBtn.isAccessibilityElement = true
//        crowdTrackingBtn.accessibilityLabel = "Crowd Tracking"
    }
    
    
}

