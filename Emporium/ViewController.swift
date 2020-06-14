//
//  ViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 19/5/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Combine

class ViewController: EmporiumNotificationViewController {

    @IBOutlet weak var notificationTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.tableView = notificationTableView
        
//        self.notificationTableView.dataSource = self
//        self.notificationTableView.delegate = self
    }
    
    
}

