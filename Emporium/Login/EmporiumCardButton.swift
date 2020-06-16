//
//  EmporiumCardButton.swift
//  Emporium
//
//  Created by Riyfhx on 15/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import MaterialComponents.MaterialCards

@IBDesignable
class EmporiumCardButton : MDCCard{
    
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    @IBInspectable var text: String?
    
    private var nibName = "EmporiumCardButton"
    
    override func awakeFromNib() {
        super.awakeFromNib()
         xibSetup()
    }

    func xibSetup() {
        guard let view = loadViewFromNib() else { return }
        view.frame = bounds
         view.autoresizingMask =
                    [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        contentView = view
    }

    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(
                    withOwner: self,
                    options: nil).first as? UIView
    }
    
    override func prepareForInterfaceBuilder() {
        self.prepareForInterfaceBuilder()
        xibSetup()
        contentView.prepareForInterfaceBuilder()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)

        if newWindow != nil {
           self.textLabel.text = text
        }
    }
    
    
}
