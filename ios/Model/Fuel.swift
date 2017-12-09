//
//  Engine.swift
//  ios
//
//  Created by Konrad Fischer on 16.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Fuel: DictionaryConvertible {
    let name: String
    var isSelected: Bool
    let id: Int
    
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let fuelName = dict["fuel"] as? String else {
                return nil
        }
        self.init(id: id, name: fuelName)
    }
    
    var dict: [String : AnyObject] {
        // TODO
        return [:]
    }
    
    init(id: Int, name: String) {
        self.name = name
        self.isSelected = false
        self.id = id
    }
    
    func toggleSelected() {
        self.isSelected = !self.isSelected
    }
}
