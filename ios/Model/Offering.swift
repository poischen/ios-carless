//
//  Car.swift
//  iOS Cars
//
//  Created by Konrad Fischer on 02.11.17.
//  Copyright © 2017 Konrad Fischer. All rights reserved.
//

class Offering: DictionaryConvertible {
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let offeringBrandID = dict["brandID"] as? Int,
              let offeringConsumption = dict["consumption"] as? Int,
              let offeringDescription = dict["description"] as? String,
              let offeringFuelID = dict["fuelID"] as? Int,
              let offeringGearID = dict["gearID"] as? Int,
              let offeringHP = dict["hp"] as? Int,
              let offeringLatitude = dict["latitude"] as? Float,
              let offeringLocation = dict["location"] as? String,
              let offeringLongitude = dict["longitude"] as? Float,
              let offeringPictureURL = dict["picture"] as? String,
              let offeringPrice = dict["price"] as? Int,
              let offeringSeats = dict["seats"] as? Int,
              let offeringType = dict["type"] as? String,
              let offeringUserUID = dict["uid"] as? String,
              let offeringVehicleTypeID = dict["vehicleTypeID"] as? Int else {
                  return nil
        }
        self.init(id: id, brandID: offeringBrandID, consumption: offeringConsumption, description: offeringDescription, fuelID: offeringFuelID, gearID: offeringGearID, hp: offeringHP, latitude: offeringLatitude, location: offeringLocation, longitude: offeringLongitude, pictureURL: offeringPictureURL, basePrice: offeringPrice, seats: offeringSeats, type: offeringType, vehicleTypeID: offeringVehicleTypeID, userUID: offeringUserUID)
    }
    
    var dict: [String : AnyObject] {
        // TODO
        return [:]
    }
    
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
    let vehicleTypeID: Int
    let userUID: String
    
    // TODO: add featureIDs back in
    
    init(id: Int, brandID: Int, consumption: Int, description: String, fuelID: Int, gearID: Int, hp: Int, latitude: Float, location: String, longitude: Float, pictureURL: String, basePrice: Int, seats: Int, type: String, vehicleTypeID: Int, userUID: String) {
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
        self.vehicleTypeID = vehicleTypeID
        self.userUID = userUID
    }
}
