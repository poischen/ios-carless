//
//  Brand.swift
//  ios
//
//  Created by Konrad Fischer on 21.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Brand: DictionaryConvertibleStatic, SelectableItem {
    
    // constants for the dictionary keys
    static let BRAND_NAME_KEY = "brand"
    
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let brandName = dict[Brand.BRAND_NAME_KEY] as? String else {
            return nil
        }
        self.init(id: id, name: brandName)
    }
    
    let id: Int
    let name: String
    var isSelected: Bool
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.isSelected = false
    }
    
    var dict: [String : AnyObject] {
        return [
            Brand.BRAND_NAME_KEY: self.name as AnyObject
        ]
    }
}
