//
//  ShoppingListViewController.swift
//  Emporium
//
//  Created by hsienxiang on 31/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

class ShoppingListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableview: UITableView!
    
    var cartData: [Cart] = []
    var list: [ShoppingList] = []
    var listName: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        loadList()
    }
    
    func loadList() {
        ShopDataManager.loadShoppingList() {
            name in
            self.listName = name
            self.tableview.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell", for: indexPath)
        cell.textLabel?.text = listName[indexPath.row]
        return cell
    }
}
