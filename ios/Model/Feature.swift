//
//  Extra.swift
//  ios
//
//  Created by Konrad Fischer on 11.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Feature: DictionaryConvertible {
    let name: String
    let id: Int
    let iconURL: String
    var isSelected: Bool
    
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let featureName = dict["type"] as? String,
              let featureIconURL = dict["icon_dl"] as? String else {
            return nil
        }
        self.init(id: id, name: featureName, iconURL: featureIconURL)
    }
    
    var dict: [String : AnyObject] {
        // TODO
        return [:]
    }
    
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
