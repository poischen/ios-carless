//
//  Filter.swift
//  ios
//
//  Created by Konrad Fischer on 17.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Filter {
    var brandIDs: [Int]?
    var maxConsumption: Int?
    var fuelIDs: [Int]?
    var gearIDs: [Int]?
    var minHP: Int?
    var location: String?
    var maxPrice: Int?
    var minSeats: Int?
    var vehicleTypeIDs: [Int]?
    var dateInterval: DateInterval?
    var featureIDs: [Int]?
    
    init(brandIDs: [Int]?, maxConsumption: Int?, fuelIDs: [Int]?, gearIDs: [Int]?, minHP: Int?, location: String?, maxPrice: Int?, minSeats: Int?, vehicleTypeIDs: [Int]?, dateInterval: DateInterval?, featureIDs: [Int]?) {
        self.brandIDs = brandIDs
        self.maxConsumption = maxConsumption
        self.fuelIDs = fuelIDs
        self.gearIDs = gearIDs
        self.minHP = minHP
        self.location = location
        self.maxPrice = maxPrice
        self.minSeats = minSeats
        self.vehicleTypeIDs = vehicleTypeIDs
        self.dateInterval = dateInterval
        self.featureIDs = featureIDs
    }
}
