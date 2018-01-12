//
//  Engine.swift
//  ios
//
//  Created by Konrad Fischer on 16.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Fuel: DictionaryConvertible, SelectableItem {
    
    // constants for the dictionary keys
    static let FUEL_NAME_KEY = "fuel"
    static let FUEL_ICON_URL_KEY = "icon_dl"
    
    let name: String
    var isSelected: Bool
    let id: Int
    let iconURL: String
    
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let fuelName = dict[Fuel.FUEL_NAME_KEY] as? String,
              let fuelIconURL = dict[Fuel.FUEL_ICON_URL_KEY] as? String else {
                return nil
        }
        self.init(id: id, name: fuelName, iconURL: fuelIconURL)
    }
    
    var dict: [String : AnyObject] {
        return [
            Fuel.FUEL_NAME_KEY : self.name as AnyObject,
            Fuel.FUEL_ICON_URL_KEY : self.iconURL as AnyObject
        ]
    }
    
    init(id: Int, name: String, iconURL: String) {
        self.name = name
        self.isSelected = false
        self.id = id
        self.iconURL = iconURL
    }
}
