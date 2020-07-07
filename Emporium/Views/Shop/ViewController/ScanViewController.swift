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
    @IBOutlet weak var cameraBtn: UIButton!
    
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
            
            if error == nil {
                print(error)
            }else{
                print(result!)
            }
        }
    }
    
}
