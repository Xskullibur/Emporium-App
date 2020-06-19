//
//  EmporiumCardButton.swift
//  Emporium
//
//  Created by Riyfhx on 15/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialCards

class EmporiumCardButton : MDCCard{
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private var onTapped: (() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let view = UINib(nibName: "EmporiumCardButton", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
        addSubview(view)

        self.setBorderWidth(1, for: .normal)
        self.setBorderColor(UIColor.gray.withAlphaComponent(0.3), for: .normal)
        self.setShadowElevation(ShadowElevation(6), for: .normal)
        
        
    }
    
    func update(text: String, image: UIImage){
        self.textLabel.text = text;
        self.imageView.image = image
    }
    
    func setTapped(_ tapped: @escaping () -> Void){
        self.onTapped = tapped
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.onTapped?()
    }
    
}
