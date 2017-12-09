//
//  CarType.swift
//  ios
//
//  Created by Konrad Fischer on 04.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class VehicleType: DictionaryConvertible {
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let typeName = dict["type"] as? String,
              let typeIconURL = dict["icon_dl"] as? String else {
                return nil
        }
        self.init(id: id, name: typeName, iconURL: typeIconURL)
    }
    
    var dict: [String : AnyObject] {
        return [
            "icon_dl": self.iconURL as AnyObject,
            "type": self.name as AnyObject
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
    
    func toggleSelected() {
        self.isSelected = !self.isSelected
    }
}
