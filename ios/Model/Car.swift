//
//  Car.swift
//  iOS Cars
//
//  Created by Konrad Fischer on 02.11.17.
//  Copyright © 2017 Konrad Fischer. All rights reserved.
//

import UIKit

class Car {
    let model: Int
    let gearshift: Int
    let mileage: Double
    let fuel: Int
    let seats: Int
    let extras: [String]
    let location: String
    let photo: UIImage?
    let rating: Int
    
    init?(model: Int, gearshift: Int, mileage: Double, fuel: Int, seats: Int, extras: [String], location: String, photo: UIImage?, rating: Int) {
        if rating < 0  {
            return nil
        }
        
        self.model = model
        self.gearshift = gearshift
        self.mileage = mileage
        self.fuel = fuel
        self.seats = seats
        self.extras = extras
        self.location = location
        self.photo = photo
        self.rating = rating
    }
}
