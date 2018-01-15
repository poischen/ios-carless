//
//  Selectable.swift
//  ios
//
//  Created by Konrad Fischer on 18.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

// interface for selectable items (e.g. the filter items in the lists in the filter view)

protocol SelectableItem {
    var isSelected:Bool {get set}
    var name:String {get}
}

extension SelectableItem {
    mutating func toggleSelected(){
        self.isSelected = !self.isSelected
    }
}
