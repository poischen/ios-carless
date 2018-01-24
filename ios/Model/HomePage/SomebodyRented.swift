//
//  SomebodyRented.swift
//  ios
//
//  Created by Konrad Fischer on 23.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation

class SomebodyRented: RentingEvent {
    let type: RentingEventType = .somebodyRented
    let renting: Renting
    let offering: Offering
    let brand: Brand
    let isRateable: Bool
    let userThatRented: User
    
    init(renting: Renting, offering: Offering, brand: Brand, userThatRented: User, isRateable: Bool) {
        self.renting = renting
        self.offering = offering
        self.brand = brand
        self.isRateable = isRateable
        self.userThatRented = userThatRented
    }
}
