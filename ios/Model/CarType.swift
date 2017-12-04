//
//  CarType.swift
//  ios
//
//  Created by Konrad Fischer on 04.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class VehicleType {
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
