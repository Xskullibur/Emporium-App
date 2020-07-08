//
//  ScanViewController.swift
//  Emporium
//
//  Created by hsienxiang on 7/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import MLKit

class ScanViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var galleryBtn: UIButton!
    
    var scanNumber: String = ""
    var scanDate: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func galleryBtnPressed(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        
        self.present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        getImageData(imageInput: info[.editedImage] as! UIImage)
        picker.dismiss(animated: true)
    }
    
    func getImageData(imageInput: UIImage) {
        let imageInput = VisionImage(image: imageInput)
        let textRec = TextRecognizer.textRecognizer()
        
        textRec.process(imageInput) {
            result, error in
            
            if error != nil {
                print(error)
            }else{
                let resultText = result!.text
                let resultArray = resultText.components(separatedBy: "\n")
                
                for item in resultArray {
                    let noWhiteSpace = String(item.filter { !" \n\t\r".contains($0)})
                    let number = noWhiteSpace.filter("0123456789".contains)
                    
                    if number.count == 16 {
                        let pattern = "\\d{16}"
                        let result = noWhiteSpace.range(of: pattern, options: .regularExpression)
                        
                        if result != nil {
                            print(noWhiteSpace)
                            self.scanNumber = noWhiteSpace
                        }
                    }
                    
                    if noWhiteSpace.contains("/") {
                        let date = noWhiteSpace.filter("0123456789/".contains)
                        print(date)
                    }
                    
                }
                
                self.navigationController?.popViewController(animated: true)
                //print(resultText)
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("test")
        (viewController as? AddCardViewController)?.scanNumber = "test"
    }
}


//^(?:4[0-9]{12}(?:[0-9]{3})?|[25][1-7][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$
