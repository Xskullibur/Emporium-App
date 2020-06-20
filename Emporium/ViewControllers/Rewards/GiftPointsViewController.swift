//
//  GiftPointsViewController.swift
//  Emporium
//
//  Created by Riyfhx on 20/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import UIKit
import Lottie

class GiftPointsViewController: UIViewController {


    @IBOutlet weak var giftAnimationView: AnimationView!
    @IBOutlet weak var pointsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Set up animation
        giftAnimationView.animation = Animation.named("gift-opening-animation")
        giftAnimationView.contentMode = .scaleAspectFill
        giftAnimationView.play()
    }
    

    func setPoints(points: Int){
        pointsLabel.text = "\(points) Points"
    }
    
    @IBAction func okPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
