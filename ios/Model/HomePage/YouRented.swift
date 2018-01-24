//
//  YouRented.swift
//  ios
//
//  Created by Konrad Fischer on 24.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation

class YouRented: RentingEvent {
    let type: RentingEventType = .youRented
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
