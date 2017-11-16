//
//  Engine.swift
//  ios
//
//  Created by Konrad Fischer on 16.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Engine {
    let id: Int
    let name: String
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
