//
//  ListenerManager.swift
//  Emporium
//
//  Created by ITP312Grp1 on 13/7/20.
//  Copyright © 2020 NYP. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ListenerManager {
    
    var listenerList: [ListenerRegistration]
    
    init() {
        listenerList = []
    }
    
    func add(_ listener: ListenerRegistration) {
        listenerList.append(listener)
    }
    
    func clear() {
        
        if listenerList.count > 0 {
            for listener in listenerList {
                listener.remove()
            }
            
            listenerList.removeAll()
        }
        
    }
    
}
