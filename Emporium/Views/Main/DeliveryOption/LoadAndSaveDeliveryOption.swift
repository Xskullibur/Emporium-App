//
//  OnDone.swift
//  Emporium
//
//  Created by Peh Zi Heng on 14/8/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

protocol LoadAndSaveDeliveryOption {
    func load(onComplete: @escaping (DeliveryOption) -> Void)
    func save(_ deliveryOption: DeliveryOption)
}
