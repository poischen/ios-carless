//
//  Car.swift
//  iOS Cars
//
//  Created by Konrad Fischer on 02.11.17.
//  Copyright © 2017 Konrad Fischer. All rights reserved.
//

class Offering {
    
    // constants for the dictionary keys
    static let OFFERING_BRAND_ID_KEY = "brandID"
    static let OFFERING_CONSUMPTION_KEY = "consumption"
    static let OFFERING_DESCRIPTION_KEY = "description"
    static let OFFERING_FUEL_ID_KEY = "fuelID"
    static let OFFERING_GEAR_ID_KEY = "gearID"
    static let OFFERING_HP_KEY = "hp"
    static let OFFERING_LATITUDE_KEY = "latitude"
    static let OFFERING_LONGITUDE_KEY = "longitude"
    static let OFFERING_PICTURE_URL_KEY = "picture"
    static let OFFERING_PRICE_KEY = "price"
    static let OFFERING_SEATS_KEY = "seats"
    static let OFFERING_TYPE_KEY = "type"
    static let OFFERING_USER_UID_KEY = "uid"
    static let OFFERING_VEHICLE_TYPE_ID_KEY = "vehicleTypeID"
    static let OFFERING_LOCATION_KEY = "location"
    static let OFFERING_PICKUP_TIME_KEY = "pickuptime"
    static let OFFERING_RETURN_TIME_KEY = "returntime"
    
    convenience required init?(id: String?, dict: [String : AnyObject]) {
        guard let offeringBrandID = dict[Offering.OFFERING_BRAND_ID_KEY] as? Int,
            let offeringConsumption = dict[Offering.OFFERING_CONSUMPTION_KEY] as? Int,
            let offeringDescription = dict[Offering.OFFERING_DESCRIPTION_KEY] as? String,
            let offeringFuelID = dict[Offering.OFFERING_FUEL_ID_KEY] as? Int,
            let offeringGearID = dict[Offering.OFFERING_GEAR_ID_KEY] as? Int,
            let offeringHP = dict[Offering.OFFERING_HP_KEY] as? Int,
            let offeringLatitude = dict[Offering.OFFERING_LATITUDE_KEY] as? Float,
            let offeringLocation = dict[Offering.OFFERING_LOCATION_KEY] as? String,
            let offeringLongitude = dict[Offering.OFFERING_LONGITUDE_KEY] as? Float,
            let offeringPictureURL = dict[Offering.OFFERING_PICTURE_URL_KEY] as? String,
            let offeringPrice = dict[Offering.OFFERING_PRICE_KEY] as? Int,
            let offeringSeats = dict[Offering.OFFERING_SEATS_KEY] as? Int,
            let offeringType = dict[Offering.OFFERING_TYPE_KEY] as? String,
            let offeringUserUID = dict[Offering.OFFERING_USER_UID_KEY] as? String,
            let offeringVehicleTypeID = dict[Offering.OFFERING_VEHICLE_TYPE_ID_KEY] as? Int,
            let offeringPickupTimeString = dict[Offering.OFFERING_PICKUP_TIME_KEY] as? String,
            let offeringReturnTimeString = dict[Offering.OFFERING_RETURN_TIME_KEY] as? String
            else {
                return nil
        }
        
        //PROBLEM: Versuch "Time" in Firebase DB zu schreiben
        // alte Version mit pickupTime und returnTime as Time
        /*if let offeringPickupTime = Time(timestring: offeringPickupTimeRaw), let offeringReturnTime = Time(timestring: offeringReturnTimeRaw){
            self.init(id: id, brandID: offeringBrandID, consumption: offeringConsumption, description: offeringDescription, fuelID: offeringFuelID, gearID: offeringGearID, hp: offeringHP, latitude: offeringLatitude, location: offeringLocation, longitude: offeringLongitude, pictureURL: offeringPictureURL, basePrice: offeringPrice, seats: offeringSeats, type: offeringType, vehicleTypeID: offeringVehicleTypeID, userUID: offeringUserUID, pickupTime: offeringPickupTime, returnTime: offeringReturnTime)
        } else {
            return nil
        } */
        self.init(id: id, brandID: offeringBrandID, consumption: offeringConsumption, description: offeringDescription, fuelID: offeringFuelID, gearID: offeringGearID, hp: offeringHP, latitude: offeringLatitude, location: offeringLocation, longitude: offeringLongitude, pictureURL: offeringPictureURL, basePrice: offeringPrice, seats: offeringSeats, type: offeringType, vehicleTypeID: offeringVehicleTypeID, userUID: offeringUserUID, pickupTime: offeringPickupTimeString, returnTime: offeringReturnTimeString)
        
    }
    
    var dict: [String : AnyObject] {
        return [
            Offering.OFFERING_BRAND_ID_KEY: self.brandID as AnyObject,
            Offering.OFFERING_CONSUMPTION_KEY: self.consumption as AnyObject,
            Offering.OFFERING_DESCRIPTION_KEY: self.description as AnyObject,
            Offering.OFFERING_FUEL_ID_KEY: self.fuelID as AnyObject,
            Offering.OFFERING_GEAR_ID_KEY: self.gearID as AnyObject,
            Offering.OFFERING_HP_KEY: self.hp as AnyObject,
            Offering.OFFERING_LATITUDE_KEY: self.latitude as AnyObject,
            Offering.OFFERING_LOCATION_KEY: self.location as AnyObject,
            Offering.OFFERING_LONGITUDE_KEY: self.longitude as AnyObject,
            Offering.OFFERING_PICTURE_URL_KEY: self.pictureURL as AnyObject,
            Offering.OFFERING_PRICE_KEY: self.basePrice as AnyObject,
            Offering.OFFERING_SEATS_KEY: self.seats as AnyObject,
            Offering.OFFERING_TYPE_KEY: self.type as AnyObject,
            Offering.OFFERING_USER_UID_KEY: self.userUID as AnyObject,
            Offering.OFFERING_VEHICLE_TYPE_ID_KEY: self.vehicleTypeID as AnyObject,
            Offering.OFFERING_PICKUP_TIME_KEY: self.pickupTime as AnyObject,
            Offering.OFFERING_RETURN_TIME_KEY: self.returnTime as AnyObject
        ]
    }
    
    var id: String?
    var basePrice: Int
    var brandID: Int
    var consumption: Int
    var description: String
    var fuelID: Int
    var gearID: Int
    var hp: Int
    var latitude: Float
    var location: String
    var longitude: Float
    var pictureURL: String
    var seats: Int
    var type: String
    var vehicleTypeID: Int
    var userUID: String
    var pickupTime: String
    var returnTime: String
    
    init(id: String?, brandID: Int, consumption: Int, description: String, fuelID: Int, gearID: Int, hp: Int, latitude: Float, location: String, longitude: Float, pictureURL: String, basePrice: Int, seats: Int, type: String, vehicleTypeID: Int, userUID: String, pickupTime: String, returnTime: String) {
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
        self.pickupTime = pickupTime
        self.returnTime = returnTime
    }
    
}
