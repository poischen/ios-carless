//
//  Renting.swift
//  ios
//
//  Created by Konrad Fischer on 02.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Renting {
    let id: Int
    let endDate: Date
    let startDate: Date
    let userID: String
    let inseratID: Int
    
    init(id: Int, inseratID: Int, userID: String, startDate: Date, endDate: Date) {
        self.id = id
        self.inseratID = inseratID
        self.userID = userID
        self.startDate = startDate
        self.endDate = endDate
    }
}
