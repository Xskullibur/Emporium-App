//
//  UIImageView.swift
//  Emporium
//
//  Created by user1 on 17/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    
    func loadImage(url: String)
    {
        if let urlObject = URL(string: url)
        {
            DispatchQueue.global(qos: .background).async
            {
                if let imageBinary = try? Data(contentsOf: urlObject)
                {
                    DispatchQueue.main.async
                    {
                        self.image = UIImage(data: imageBinary)
                    }
                }
            }
        }
    }
}
