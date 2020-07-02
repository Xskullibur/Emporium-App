//
//  EmptyTableView.swift
//  Emporium
//
//  Created by Peh Zi Heng on 2/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Lottie

class EmptyTableView: UIView {

    // MARK: - Outlets
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var textLabel: UILabel!
    
    // MARK: - Variables
    var message: String {
        set {
            textLabel.text = newValue
        }
        get {
            return textLabel.text ?? ""
        }
    }
    
    /**
     Set the animation use for displaying empty table
     */
    func setAnimation(_ animation: Animation){
        self.animationView.animation = animation
        self.animationView.loopMode = .loop
        self.animationView.play()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
