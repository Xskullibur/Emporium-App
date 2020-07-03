//
//  EmporiumVoucherError.swift
//  Emporium
//
//  Created by Peh Zi Heng on 19/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

enum VoucherStatus {
    case success
    case notEnoughPoints
    case error(Error)
}
