//
//  Extra.swift
//  ios
//
//  Created by Konrad Fischer on 11.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Feature: DictionaryConvertibleStatic, SelectableItem {
    
    // constants for the dictionary keys
    static let FEATURE_NAME_KEY = "type"
    static let FEATURE_ICON_URL_KEY = "icon_dl"
    
    let name: String
    let id: Int
    let iconURL: String
    var isSelected: Bool
    
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let featureName = dict[Feature.FEATURE_NAME_KEY] as? String,
              let featureIconURL = dict[Feature.FEATURE_ICON_URL_KEY] as? String else {
            return nil
        }
        self.init(id: id, name: featureName, iconURL: featureIconURL)
    }
    
    var dict: [String : AnyObject] {
        return [
            Feature.FEATURE_NAME_KEY : self.name as AnyObject,
            Feature.FEATURE_ICON_URL_KEY : self.iconURL as AnyObject
        ]
    }
    
    init(id: Int, name: String, iconURL: String) {
        self.name = name
        self.id = id
        self.iconURL = iconURL
        self.isSelected = false
    }
}
