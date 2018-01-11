//
//  Location.swift
//  ios
//
//  Created by Konrad Fischer on 10.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation

class Point {
    let latitude:Double
    let longitude:Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func distanceToPoint(otherPoint: Point) -> Double {
        return Point.distanceBetweenPoints(place1Latitude: self.latitude, place1Longitude: self.longitude, place2Latitude: otherPoint.latitude, place2Longitude: otherPoint.longitude)
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
