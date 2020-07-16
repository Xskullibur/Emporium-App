//
//  EmptyTableView.swift
//  Emporium
//
//  Created by Peh Zi Heng on 2/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import UIKit
import Lottie

extension UITableView {

    func setEmptyMessage(_ message: String, _ animation: Animation? = nil) {
        
        let view = UINib(nibName: "EmptyTableView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! EmptyTableView
        
        if let animation = animation {
            view.setAnimation(animation)
        }else{
            let defaultAnimation = Animation.named("empty")!
            view.setAnimation(defaultAnimation)
        }
        
        view.message = message
        view.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        
//        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
//        messageLabel.text = message
//        messageLabel.textColor = .black
//        messageLabel.numberOfLines = 0
//        messageLabel.textAlignment = .center
//        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
//        messageLabel.sizeToFit()

        self.backgroundView = view
        self.separatorStyle = .none
    }

    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
