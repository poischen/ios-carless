//
//  Filter.swift
//  ios
//
//  Created by Konrad Fischer on 17.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

struct Filter {
    let maxPrice: Int?
    let minSeats: Int?
    let city: String?
    
    init(maxPrice: Int, minSeats: Int, city: String) {
        self.maxPrice = maxPrice
        self.minSeats = minSeats
        self.city = city
    }
}
