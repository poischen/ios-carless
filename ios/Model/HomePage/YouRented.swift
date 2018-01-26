//
//  YouRented.swift
//  ios
//
//  Created by Konrad Fischer on 24.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation

// This class represents a renting by the currently logged in user for display on the home page.

class YouRented: RentingEvent {
    let type: RentingEventType = .youRented // necessary for identifiying the type of an element in an array of elements of different types
    let renting: Renting
    let offering: Offering
    let brand: Brand
    let isRateable: Bool
    
    init(renting: Renting, offering: Offering, brand: Brand, isRateable: Bool) {
        self.renting = renting
        self.offering = offering
        self.brand = brand
        self.isRateable = isRateable
    }
}
