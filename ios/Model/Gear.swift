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

class Gear: DictionaryConvertible {
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let gearName = dict["gear"] as? String else {
            return nil
        }
        self.init(id: id, name: gearName)
    }
    
    let name: String
    var isSelected: Bool
    let id: Int
    
    init(id:Int, name: String) {
        self.id = id
        self.isSelected = false
        self.name = name
    }
    
    var dict: [String : AnyObject] {
        return [
            "gear": self.name as AnyObject,
        ]
    }
    
    func toggleSelected() {
        self.isSelected = !self.isSelected
    }
}
