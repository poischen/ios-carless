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
    let iconURL: String
    var isSelected: Bool
    
    init(id: Int, name: String, iconURL: String) {
        self.name = name
        self.id = id
        self.iconURL = iconURL
        self.isSelected = false
    }
    
    func toggleSelected() {
        self.isSelected = !self.isSelected
    }
}
