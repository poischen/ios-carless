//
//  Filter.swift
//  ios
//
//  Created by Konrad Fischer on 17.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Filter {
    // filter criteria
    // if a criterion is nill it will be ignored
    var brandIDs: [Int]?
    var maxConsumption: Int?
    var fuelIDs: [Int]?
    var gearIDs: [Int]?
    var minHP: Int?
    var maxPrice: Int?
    var minSeats: Int?
    var vehicleTypeIDs: [Int]?
    var dateInterval: DateInterval?
    var featureIDs: [Int]?
    var placePoint: CoordinatePoint?
    
    init(brandIDs: [Int]?, maxConsumption: Int?, fuelIDs: [Int]?, gearIDs: [Int]?, minHP: Int?, maxPrice: Int?, minSeats: Int?, vehicleTypeIDs: [Int]?, dateInterval: DateInterval?, featureIDs: [Int]?, placePoint: CoordinatePoint?) {
        self.brandIDs = brandIDs
        self.maxConsumption = maxConsumption
        self.fuelIDs = fuelIDs
        self.gearIDs = gearIDs
        self.minHP = minHP
        self.placePoint = placePoint
        self.maxPrice = maxPrice
        self.minSeats = minSeats
        self.vehicleTypeIDs = vehicleTypeIDs
        self.dateInterval = dateInterval
        self.featureIDs = featureIDs
    }
    
    static func distanceBetweenPoints(place1Latitude: Double, place1Longitude: Double, place2Latitude: Double, place2Longitude: Double) -> Double{
        // source: https://www.movable-type.co.uk/scripts/latlong.html (adapted for Swift)
        let earthRadius = Double(6371 * 1000) // meters (6371 kilometers)
        let place1LatRadians = degreesToRadians(degrees: place1Latitude)
        let place2LatRadians = degreesToRadians(degrees: place2Latitude)
        let deltaLatRadians = degreesToRadians(degrees: (place2Latitude - place1Latitude))
        let deltaLongRadians = degreesToRadians(degrees: (place2Longitude - place1Longitude))
        
        let a = sin(deltaLatRadians/2) * sin(deltaLatRadians/2) + cos(place1LatRadians) * cos(place2LatRadians) * sin(deltaLongRadians/2) * sin(deltaLongRadians/2);
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return earthRadius * c // distance is returned in METERS
    }
    
    static func degreesToRadians(degrees: Double) -> Double{
        return degrees * .pi / 180
    }

    
}
