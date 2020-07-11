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
    
    var scanNumber: String = ""
    var scanDate: String = ""
    let scan = Scan()
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
                
            }else{
                let resultText = result!.text
                let resultArray = resultText.components(separatedBy: "\n")
                
                let details =  self.scan.extractValue(items: resultArray)
                print("test number " + details.cardNumber)
                print("test bank " + String(details.bank))
                self.scan.extractName(results: resultArray)
            }
        }
    }
    
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("test")
        (viewController as? AddCardViewController)?.scanNumber = "test"
    }
}
