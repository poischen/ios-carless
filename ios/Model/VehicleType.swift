//
//  CarType.swift
//  ios
//
//  Created by Konrad Fischer on 04.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class VehicleType: DictionaryConvertible, SelectableItem {
    
    // constants for the dictionary keys
    static let VEHICLETYPE_ICON_URL_KEY = "icon_dl"
    static let VEHICLETYPE_NAME_KEY = "type"
    
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let typeName = dict[VehicleType.VEHICLETYPE_NAME_KEY] as? String,
              let typeIconURL = dict[VehicleType.VEHICLETYPE_ICON_URL_KEY] as? String else {
                return nil
        }
        self.init(id: id, name: typeName, iconURL: typeIconURL)
    }
    
    var dict: [String : AnyObject] {
        return [
            VehicleType.VEHICLETYPE_ICON_URL_KEY: self.iconURL as AnyObject,
            VehicleType.VEHICLETYPE_NAME_KEY: self.name as AnyObject
        ]
    }
    
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
}
