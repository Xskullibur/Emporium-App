//
//  RequestorsListViewController.swift
//  Emporium
//
//  Created by Xskullibur on 24/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit

// Order Cell
class ItemCell: UITableViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
}

class RequestorsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Variables
    var cartList: [Cart2] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemCell
        
        let item = cartList[row]
        cell.productImage.loadImage(url: item.product.image)
        cell.nameLabel.text = item.product.productName
        cell.quantityLabel.text = "$\(item.product.price)"
        
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
