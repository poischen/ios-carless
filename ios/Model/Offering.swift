//
//  Car.swift
//  iOS Cars
//
//  Created by Konrad Fischer on 02.11.17.
//  Copyright © 2017 Konrad Fischer. All rights reserved.
//

class Offering {
    let id: Int
    let basePrice: Int
    let brandID: Int
    let consumption: Int
    let description: String
    let fuelID: Int
    let gearID: Int
    let hp: Int
    let latitude: Float
    let location: String
    let longitude: Float
    let pictureURL: String
    let seats: Int
    let type: String
    let featuresIDs: [Int]?
    let vehicleTypeID: Int
    
    init(id: Int, brandID: Int, consumption: Int, description: String, fuelID: Int, gearID: Int, hp: Int, latitude: Float, location: String, longitude: Float, pictureURL: String, basePrice: Int, seats: Int, type: String, featuresIDs: [Int]?, vehicleTypeID: Int) {
        self.basePrice = basePrice
        self.id = id
        self.brandID = brandID
        self.consumption = consumption
        self.description = description
        self.fuelID = fuelID
        self.gearID = gearID
        self.hp = hp
        self.latitude = latitude
        self.longitude = longitude
        self.pictureURL = pictureURL
        self.seats = seats
        self.type = type
        self.location = location
        self.featuresIDs = featuresIDs
        self.vehicleTypeID = vehicleTypeID
    }
}
