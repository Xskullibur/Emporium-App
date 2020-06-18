//
//  EmporiumLoginViewController.swift
//  Emporium
//
//  Created by Peh Zi Heng on 8/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation


import UIKit
import FirebaseUI

class EmporiumLoginViewController: FUIAuthPickerViewController {

  @IBAction func onClose(_ sender: AnyObject) {
    self.cancelAuthorization()
  }

}
