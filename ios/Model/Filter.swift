//
//  Filter.swift
//  ios
//
//  Created by Konrad Fischer on 17.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

struct Filter {
    var maxPrice: Int?
    var minSeats: Int?
    var city: String?
    var maxConsumption: Int?
    var minHP: Int?
    var gearshifts: [Gear]?
    var brands: [Brand]?
    var engines: [Fuel]?
    var featureIDs: [Int]?
    var dateInterval: DateInterval?
    var vehicleTypeIDs: [Int]?
    
    init(maxPrice: Int?, minSeats: Int?, city: String?, maxConsumption: Int?, minHP: Int?, gearshift: [Gear]?, brands: [Brand]?, engines: [Fuel]?, featureIDs: [Int]?, dateInterval: DateInterval?, vehicleTypeIDs: [Int]?) {
        self.maxPrice = maxPrice
        self.minSeats = minSeats
        self.city = city
        self.maxConsumption = maxConsumption
        self.minHP = minHP
        self.gearshifts = gearshift
        self.brands = brands
        self.engines = engines
        self.dateInterval = dateInterval
        self.vehicleTypeIDs = vehicleTypeIDs
    }
}
