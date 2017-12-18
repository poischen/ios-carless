//
//  Selectable.swift
//  ios
//
//  Created by Konrad Fischer on 18.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

protocol SelectableItem {
    var isSelected:Bool {get set}
    var name:String {get set}
}

extension SelectableItem {
    mutating func toggleSelected(){
        self.isSelected = !self.isSelected
    }
}
