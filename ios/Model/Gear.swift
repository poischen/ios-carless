//
//  Gear.swift
//  ios
//
//  Created by Konrad Fischer on 25.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation


class Gear: DictionaryConvertibleStatic, SelectableItem {
    
    // constants for the dictionary keys
    static let GEAR_NAME_KEY = "gear"
    static let GEAR_ICON_URL_KEY = "icon_dl"
    
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let gearName = dict[Gear.GEAR_NAME_KEY] as? String,
              let gearIconURL = dict[Gear.GEAR_ICON_URL_KEY] as? String else {
            return nil
        }
        self.init(id: id, name: gearName, iconURL: gearIconURL)
    }
    
    let name: String
    var isSelected: Bool
    let id: Int
    let iconURL: String
    
    init(id:Int, name: String, iconURL: String) {
        self.id = id
        self.isSelected = false
        self.name = name
        self.iconURL = iconURL
    }
    
    var dict: [String : AnyObject] {
        return [
            Gear.GEAR_NAME_KEY: self.name as AnyObject,
            Gear.GEAR_ICON_URL_KEY: self.iconURL as AnyObject
        ]
    }
}
