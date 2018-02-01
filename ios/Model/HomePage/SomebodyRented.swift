//
//  SomebodyRented.swift
//  ios
//
//  Created by Konrad Fischer on 23.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation

// This class represents a renting of a car that belongs to the user that's currently logged in for display on the home page.

class SomebodyRented: RentingEvent {
    let type: RentingEventType = .somebodyRented // necessary for identifiying the type of an element in an array of elements of different types
    let renting: Renting
    let offering: Offering
    let brand: Brand
    let isRateable: Bool
    let userThatRented: User
    let coUser: User
    
    init(renting: Renting, offering: Offering, brand: Brand, userThatRented: User, isRateable: Bool, coUser: User) {
        self.renting = renting
        self.offering = offering
        self.brand = brand
        self.isRateable = isRateable
        self.userThatRented = userThatRented
        self.coUser = coUser
    }
}
