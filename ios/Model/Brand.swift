//
//  Brand.swift
//  ios
//
//  Created by Konrad Fischer on 21.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Brand {
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
