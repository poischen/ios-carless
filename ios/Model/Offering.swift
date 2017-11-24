//
//  Car.swift
//  iOS Cars
//
//  Created by Konrad Fischer on 02.11.17.
//  Copyright © 2017 Konrad Fischer. All rights reserved.
//

class Offering {
    let brand: String
    let consumption: Int
    let description: String
    let fuel: String
    let gear: String
    let hp: Int
    let latitude: Float
    let location: String
    let longitude: Float
    let pictureURL: String
    let seats: Int
    let type: String
    
    init(brand: String, consumption: Int, description: String, fuel: String, gear: String, hp: Int, latitude: Float, location: String, longitude: Float, pictureURL: String, seats: Int, type: String) {
        self.brand = brand
        self.consumption = consumption
        self.description = description
        self.fuel = fuel
        self.gear = gear
        self.hp = hp
        self.latitude = latitude
        self.longitude = longitude
        self.pictureURL = pictureURL
        print(pictureURL)
        self.seats = seats
        self.type = type
        self.location = location
    }
}
