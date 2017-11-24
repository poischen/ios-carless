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
    
    init(maxPrice: Int?, minSeats: Int?, city: String?, maxConsumption: Int?) {
        self.maxPrice = maxPrice
        self.minSeats = minSeats
        self.city = city
        self.maxConsumption = maxConsumption
    }
}
