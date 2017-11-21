//
//  Extra.swift
//  ios
//
//  Created by Konrad Fischer on 11.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Feature {
    let name: String
    let id: Int
    var isSelected: Bool
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
        self.isSelected = false
    }
    
    func toggleSelected() {
        self.isSelected = !self.isSelected
    }
}
