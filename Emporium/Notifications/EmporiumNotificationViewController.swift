//
//  EmporiumNotificationViewController.swift
//  Emporium
//
//  Created by Riyfhx on 13/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Combine

class EmporiumNotificationViewController : UIViewController, UITableViewDataSource, UITableViewDelegate{

    private var cancellables = Set<AnyCancellable>()
    
    private weak var _tableView: UITableView?
    var tableView: UITableView?{
        set {
            newValue?.delegate = self
            newValue?.dataSource = self
            _tableView = newValue
        }
        get {
            return _tableView
        }
    }
    
    var notifications: [EmporiumNotification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationHandler = NotificationHandler.shared
        
        notificationHandler.create()
        
        notificationHandler.getNotifications()?
        .sink(receiveCompletion: {
            completion in
            print(completion)
        }, receiveValue: {
            notifications in
            
            self.notifications = notifications
            self.tableView?.reloadData()
        })
            .store(in: &cancellables)
        
        notificationHandler.start()
        
        self.tableView?.estimatedRowHeight = 233.0
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        
        let notification = notifications[indexPath.row]
        
        if cell.contentView.subviews.contains(where: {$0.tag == 999}) == false{
            let view = Bundle.main.loadNibNamed("NotificationTableView", owner: self, options: nil)?.first as! NotificationTableView
            
            view.tag = 999
            cell.contentView.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            view.topAnchor.constraint(equalTo: cell.contentView.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            
            view.setSeeMorePressed {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
            
            view.setNotification(notification: notification)
            
        }else{
            let view = cell.contentView.subviews.first(where: {$0.tag == 999}) as! NotificationTableView
            view.setNotification(notification: notification)
        }
        
        
        
        return cell
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
