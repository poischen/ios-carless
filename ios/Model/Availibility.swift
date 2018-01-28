//
//  Availibility.swift
//  ios
//
//  Created by admin on 02.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

// TODO: remove?

import Foundation

class Availibility {
  
    let date: Date
    var isBlocked: Bool
    
    init? (date: Date){
        self.date = date
        self.isBlocked = false
    }
}
