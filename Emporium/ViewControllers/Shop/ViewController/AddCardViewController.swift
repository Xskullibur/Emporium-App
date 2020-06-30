//
//  AddCardViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 29/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Lottie

class AddCardViewController: UIViewController {
    
    
    @IBOutlet weak var numberInput: UITextField!
    @IBOutlet weak var cvcInput: UITextField!
    @IBOutlet weak var expDatePickerView: UIPickerView!
    
    @IBOutlet weak var cardAnimation: AnimationView!
    
    var backendBaseURL: String? = "http://172.27.176.188:5000"
    
    var monthPickerData : [Int] = Array(1...12)
    var yearPickerData: [Int] = Array(2020...2070)
    var labelData: [String] = ["Exp Month", "Exp Year"]
    var cartData: [Cart] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        numberInput.placeholder = "Card Number (16 Digit)"
        cvcInput.placeholder = "CVC"
        
        //startAnimation
        self.cardAnimation.animation = Animation.named("cardAni")
        self.cardAnimation.contentMode = .scaleAspectFit
        self.cardAnimation.loopMode = .loop
        self.cardAnimation.play()
        
        self.expDatePickerView.dataSource = self
        self.expDatePickerView.delegate = self
        self.expDatePickerView.layer.cornerRadius = 10
        
        let labelWidth = expDatePickerView.frame.width / CGFloat(expDatePickerView.numberOfComponents)
        for index in 0..<labelData.count {
            let label: UILabel = UILabel.init(frame: CGRect(x: expDatePickerView.frame.origin.x + labelWidth * CGFloat(index), y: 0, width: labelWidth, height: 20))
            label.text = labelData[index]
            label.textAlignment = .center
            expDatePickerView.addSubview(label)
        }
        
        expDatePickerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        expDatePickerView.layer.shadowColor = UIColor.darkGray.cgColor
        expDatePickerView.layer.shadowRadius = 5
        expDatePickerView.layer.shadowOpacity = 0.9
        expDatePickerView.layer.masksToBounds = false
        expDatePickerView.clipsToBounds = false
    }
        
    @IBAction func addBtnPressed(_ sender: Any) {
    }
}

extension AddCardViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return monthPickerData.count
        }else{
            return yearPickerData.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(monthPickerData[row])
        }else{
            return String(yearPickerData[row])
        }
    }
}
