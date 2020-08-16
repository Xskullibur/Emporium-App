//
//  RequestorsListViewController.swift
//  Emporium
//
//  Created by Xskullibur on 24/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Lottie
import SDWebImage
import MaterialComponents.MaterialChips

class RequestorsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - Outlets
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    // MARK: - Variables
    var queueId: String!
    var store: GroceryStore!
    var order: Order!
    
    var itemList: [RequestedItem] = []
    
    var defaultCategoryList: [String] = []
    var categoryList: [String] = []
    
    var defaultData: [[RequestedItem]] = []
    var data: [[RequestedItem]] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // CategoryView
        let layout = MDCChipCollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.estimatedItemSize = CGSize(width: 60, height: 33)
        categoryCollectionView.collectionViewLayout = layout
        
        categoryCollectionView.backgroundColor = .white
        categoryCollectionView.contentInset = UIEdgeInsets(top:20,left: 20,bottom: 20,right: 20)
        categoryCollectionView.register(MDCChipCollectionViewCell.self,
                forCellWithReuseIdentifier:"categoryCell")
        categoryCollectionView.allowsMultipleSelection = true
        
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        // Get Orders and Categories
        self.showSpinner(onView: self.view)
        ShopDataManager.getOrders(order: order, onComplete: { (carts) in
            self.itemList = RequestedItem.getItems(carts: carts)
            
            let categories = self.itemList.map { $0.cart.product.category }
            self.categoryList = Array(Set(categories))
            self.defaultCategoryList = Array(Set(categories))
            
            // Split by Category
            for category in self.categoryList {
                let items = self.itemList.filter{ $0.cart.product.category == category }
                self.data.append(items)
                self.defaultData.append(items)
            }
            
            self.itemTableView.reloadData()
            self.categoryCollectionView.reloadData()
            self.removeSpinner()
        })
        
    }
    
    // MARK: - Custom Views
    enum animationType {
        case Check
        case Cross
    }
    
    func emptyView() -> UIView {
        
        let circleView = UIView()
        circleView.frame = CGRect(origin: CGPoint(x: 3, y: 3), size: CGSize(width: 42, height: 42))
        circleView.layer.cornerRadius = circleView.frame.size.width/2
        circleView.clipsToBounds = true
        circleView.layer.borderColor = UIColor.systemGray.cgColor
        circleView.layer.borderWidth = 3
        
        return circleView
        
    }
    
    func animationView(type: animationType, frame _frame: CGRect) -> AnimationView {
        
        var animationView = AnimationView()
        
        if type == .Check {
            animationView = .init(name: "check")
        } else {
            animationView = .init(name: "cross")
        }
        
        animationView.frame = _frame
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        
        return animationView
        
    }
    
    // MARK: - TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categoryList[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
        
        let item = data[section][row]
        cell.selectionStyle = .none

        cell.productImage.sd_setImage(with: URL(string: item.cart.product.image))
        cell.nameLabel.text = "\(item.cart.product.productName) x\(item.cart.quantity)"
        cell.quantityLabel.text = "$\(String(format: "%.2f", item.cart.product.price))"
        
        if cell.checkView.subviews.count > 0 {
            for view in cell.checkView.subviews {
                view.removeFromSuperview()
            }
        }
        
        switch item.status {
            
            case .NotPickedUp:
                let view = emptyView()
                cell.checkView.addSubview(view)
            
            case .PickedUp:
                let view = animationView(type: .Check, frame: cell.checkView.bounds)
                cell.checkView.addSubview(view)
                view.play()
            
            case .NotAvailable:
                let view = animationView(type: .Cross, frame: cell.checkView.bounds)
                cell.checkView.addSubview(view)
                view.play()
            
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        let section = indexPath.section
        let cell = tableView.cellForRow(at: indexPath) as! ItemTableViewCell
        
        if data[section][row].status == .PickedUp {
            // Update .NotPickedUp
            let item = data[section][row]
            item.status = .NotPickedUp
            updateRequestedItem(item: item, status: .NotPickedUp)
            
            let view = emptyView()
            cell.checkView.subviews[0].removeFromSuperview()
            cell.checkView.addSubview(view)
        }
        else {
            // Update .PickedUp (.NotPickedUp / .NotAvailable)
            let item = data[section][row]
            item.status = .PickedUp
            updateRequestedItem(item: item, status: .PickedUp)
            
            let view = animationView(type: .Check, frame: cell.checkView.bounds)
            cell.checkView.subviews[0].removeFromSuperview()
            cell.checkView.addSubview(view)
            view.play()
        }
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let row = indexPath.row
        let section = indexPath.section
        var customBtn: UIContextualAction
        
        if data[section][row].status == .NotAvailable {
            
            // .NotAvailable => .Available
            customBtn = UIContextualAction(style: .normal, title: "Available", handler: { (action, view, success) in
                
                tableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: indexPath)
                success(true)
                
            })
            customBtn.backgroundColor = .systemBlue
        }
        else {
            
            // .Available => .NotAvailable
            customBtn = UIContextualAction(style: .normal, title: "Not Available", handler: { (action, view, success) in
                
                tableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: indexPath)
                success(true)
                
            })
            customBtn.backgroundColor = .systemRed
        }
        
        let swipeActions = UISwipeActionsConfiguration(actions: [customBtn])
        return swipeActions
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        let section = indexPath.section
        
        let cell = tableView.cellForRow(at: indexPath) as! ItemTableViewCell
        
        if editingStyle == .delete {
            
            if data[section][row].status == .NotAvailable {
                
                // Update .NotAvailable => .PickedUp
                let item = data[section][row]
                item.status = .PickedUp
                updateRequestedItem(item: item, status: .PickedUp)
                
                let view = animationView(type: .Check, frame: cell.checkView.bounds)
                cell.checkView.subviews[0].removeFromSuperview()
                cell.checkView.addSubview(view)
                view.play()
                
            } else {
                
                // Update .Any => .NotAvailable
                let item = data[section][row]
                item.status = .NotAvailable
                updateRequestedItem(item: item, status: .NotAvailable)
                
                let view = animationView(type: .Cross, frame: cell.checkView.bounds)
                cell.checkView.subviews[0].removeFromSuperview()
                cell.checkView.addSubview(view)
                view.play()
                
            }
            
        }
        
    }
    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! MDCChipCollectionViewCell

        let chipView = cell.chipView
        chipView.titleLabel.text = categoryList[indexPath.row]
        chipView.sizeToFit()
        chipView.invalidateIntrinsicContentSize()
        cell.chipView.setBackgroundColor(UIColor(named: "Light"), for: .selected)

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        updateTableViewDataSource()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        updateTableViewDataSource()
    }
    
    // MARK: - Custom Functions
    func updateRequestedItem(item: RequestedItem, status: RequestedItem.ItemStatus) {
        itemList.first{ $0.cart.product.id == item.cart.product.id }!.status = status
    }
    
    func updateTableViewDataSource() {
        
        // Get Selected Categories
        guard let selectedIndexPath = categoryCollectionView.indexPathsForSelectedItems else {
            return
        }
        
        // Update Categories
        if selectedIndexPath.count > 0 {
            categoryList = []
            data = []
            
            // Add items based on selected category into data
            for index in selectedIndexPath {
                let row = index.row
                categoryList.append(defaultCategoryList[row])
                data.append(defaultData[row])
            }
        }
        else {
            categoryList = defaultCategoryList
            data = defaultData
        }
        
        itemTableView.reloadData()
        
    }
    
    // MARK: - IBAction
    @IBAction func doneBtnPressed(_ sender: Any) {
        
        // Check itemList
        let unCheckItems = itemList.filter{ $0.status == .NotPickedUp }
        if unCheckItems.count > 0 {
            
            // Alert
            let url = Bundle.main.url(forResource: "Data", withExtension: "plist")
            let data = Plist.readPlist(url!)!
            let infoDescription = data["Checklist Alert"] as! String
            self.showAlert(title: "Oops!", message: infoDescription)
            
        }
        else {
            
            var total: Double = 0
            let pickedUpItems = itemList.filter({ $0.status == .PickedUp })
            for item in pickedUpItems {
                total += item.cart.product.price * Double(item.cart.quantity)
            }
            
            // Update Queue Status
            showSpinner(onView: self.view)
            let queueDataManager = QueueDataManager()
            queueDataManager.updateQueue(queueId!, withStatus: .Delivery, forStoreId: store!.id) { (success) in
                
                self.removeSpinner()
                
                if success {
                    
                    // Update Delivery to Delivery
                    DeliveryDataManager.shared.updateDeliveryAmount(order: self.order, amount: total) {
                        DeliveryDataManager.shared.updateDeliveryStatus(status: .delivery)
                        
                        // Navigate
                        let queueStoryboard = UIStoryboard(name: "Delivery", bundle: nil)
                        let deliveryVC = queueStoryboard.instantiateViewController(identifier: "deliveryVC") as DeliveryViewController
                        
                        deliveryVC.order = self.order
                        
                        let rootVC = self.navigationController?.viewControllers.first
                        self.navigationController?.setViewControllers([rootVC!, deliveryVC], animated: true)
                    }
                    
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
