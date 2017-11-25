//
//  Gear.swift
//  ios
//
//  Created by Konrad Fischer on 25.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

// TODO: let gear, engine and feature inherit from one class or union these classes?
// TODO: more sophisticated object needed here?

class Gear {
    let name: String
    var isSelected: Bool
    
    init(name: String) {
        self.name = name
        self.isSelected = false
    }
    
    func toggleSelected() {
        self.isSelected = !self.isSelected
    }
}
