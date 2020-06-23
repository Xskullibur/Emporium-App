//
//  EarnedRewards.swift
//  Emporium
//
//  Created by Riyfhx on 20/6/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation

struct EarnedReward {
    let id: String
    let earnedAmount: Int
    let earnedDate: Date
    
    let displayed: Bool// Have this earned rewards been shown the user
}
