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

        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.allowsEditing = true
        picker.sourceType = .camera
        
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
                        }
                    }
                    
                    if noWhiteSpace.contains("/") {
                        let date = noWhiteSpace.filter("0123456789/".contains)
                        let dateArray = date.components(separatedBy: "/")
                        
                        if dateArray[0] != "" {
                            if 0...12 ~= Int(dateArray[0])! {
                                
                            }
                        }
                        
                        if dateArray[1] != "" {
                            if 20...70 ~= Int(dateArray[1])! {
                                
                            }
                        }
                        
                        print(date)
                    }
                    
                }
                print(resultText)
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("test")
        (viewController as? AddCardViewController)?.scanNumber = "test"
    }
}
