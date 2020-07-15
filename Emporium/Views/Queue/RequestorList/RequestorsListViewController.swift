//
//  RequestorsListViewController.swift
//  Emporium
//
//  Created by Xskullibur on 24/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Lottie
import MaterialComponents.MaterialChips

class RequestorsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    // MARK: - Variables
    var itemList: [RequestedItem] = []
    var categoryList: [String] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #warning("TODO: Remove test data")
        itemList = RequestedItem.getDebug()
        
        let layout = MDCChipCollectionViewFlowLayout()
        categoryCollectionView.collectionViewLayout = layout
        
        categoryCollectionView.dataSource = self
        categoryCollectionView.delegate = self
        
        // Get Categories
        let categories = itemList.map { $0.cart.product.category }
        categoryList = Array(Set(categories))
        
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemTableViewCell
        
        let item = itemList[row]
        cell.selectionStyle = .none
        cell.productImage.loadImage(url: item.cart.product.image)
        cell.nameLabel.text = item.cart.product.productName
        cell.quantityLabel.text = "\(item.cart.quantity)"
        
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
        let cell = tableView.cellForRow(at: indexPath) as! ItemTableViewCell
        
        if itemList[row].status == .NotPickedUp {
            
            // Update .NotPickedUp to .PickedUp
            itemList[row].status = .PickedUp
            let view = animationView(type: .Check, frame: cell.checkView.bounds)
            cell.checkView.subviews[0].removeFromSuperview()
            cell.checkView.addSubview(view)
            view.play()
            
        }
        else if itemList[row].status == .PickedUp {
            
            // Update .PickedUp to .NotPickedUp
            itemList[row].status = .NotPickedUp
            let view = emptyView()
            cell.checkView.subviews[0].removeFromSuperview()
            cell.checkView.addSubview(view)
            
        }
        else if itemList[row].status == .NotAvailable {
            
            // Update .NotAvailable to .PickedUp
            itemList[row].status = .PickedUp
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
        var customBtn: UIContextualAction
        
        if itemList[row].status == .NotAvailable {
            customBtn = UIContextualAction(style: .normal, title: "Available", handler: { (action, view, success) in
                
                tableView.dataSource?.tableView?(tableView, commit: .delete, forRowAt: indexPath)
                success(true)
                
            })
            customBtn.backgroundColor = .systemBlue
        }
        else {
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
        let cell = tableView.cellForRow(at: indexPath) as! ItemTableViewCell
        
        if editingStyle == .delete {
            
            if itemList[row].status == .NotAvailable {
                
                // Update NotAvailable => .PickedUp
                itemList[row].status = .PickedUp
                let view = animationView(type: .Check, frame: cell.checkView.bounds)
                cell.checkView.subviews[0].removeFromSuperview()
                cell.checkView.addSubview(view)
                view.play()
                
            } else {
                
                // Update Any => .NotAvailable
                itemList[row].status = .NotAvailable
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
        chipView.setTitleColor(UIColor.red, for: .normal)
        chipView.backgroundColor = .magenta
        chipView.sizeToFit()
        chipView.invalidateIntrinsicContentSize()

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
