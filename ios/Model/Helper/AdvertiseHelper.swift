//
//  AdvertiseHelper.swift
//  ios
//
//  Created by admin on 09.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation

/*
 * Caches input data while advertiseing: offer, availibility, features
 */

class AdvertiseHelper {
 
    let advertiseOffer = Advertise.shared
    
    //cache input for storing offering data into db
    var id: String?
    var basePrice: Int?
    var brandID: Int?
    var consumption: Int?
    var description: String?
    var fuelID: Int?
    var gearID: Int?
    var hp: Int?
    var latitude: Float?
    var location: String?
    var longitude: Float?
    var pictureURL: String?
    var seats: Int?
    var type: String?
    var vehicleTypeID: Int?
    var userUID: String?
    var pickupTime: String?
    var returnTime: String?
    
    //cache input for storing availibility data into db
    var blockedDates: [Date] = []
    
    //cache input for storing features data into db
    //todo

    func convertAndCacheOfferingData(input: String, key: String, conversionType: String){
        if (conversionType == Advertise.ADVERTISE_CONVERSION_SEATS){
            
            var seats = input
            if (input == "more"){
                seats = "9"
            }
            let seatsInt: Int = Int(seats)!
            self.seats = seatsInt
            
        } else {
            
            let inputString = input
            
            switch (conversionType) {
            case Advertise.ADVERTISE_CONVERSION_BRANDS:
                self.brandID = advertiseOffer.brandsDict[inputString]
                
            case Advertise.ADVERTISE_CONVERSION_FUELS:
                self.fuelID = advertiseOffer.fuelsDict[inputString]
                
            case Advertise.ADVERTISE_CONVERSION_GEARS:
                self.gearID = advertiseOffer.gearsDict[inputString]
                
            case Advertise.ADVERTISE_CONVERSION_VEHICLETYPES:
                self.vehicleTypeID = advertiseOffer.vehicleTypesDict[inputString]
                
            default:
                break
            }
    }
}
    
    func getOfferDict() -> [String : AnyObject] {
        var offeringDict: [String : AnyObject] = [ : ]
        
        if let brandID = self.brandID, let consumption = self.consumption, let description = self.description, let fuel = self.fuelID, let gear = self.gearID, let speed = self.hp, let latitute = self.latitude, let location = self.location, let longitute = self.longitude, let imgURL = self.pictureURL, let price = self.basePrice, let seats = self.seats, let carName = self.type, let user = self.userUID, let vehicleType = self.vehicleTypeID, let pickupTime = self.pickupTime, let returnTime = self.returnTime {
            offeringDict.updateValue(brandID as AnyObject, forKey: Offering.OFFERING_BRAND_ID_KEY)
            offeringDict.updateValue(consumption as AnyObject, forKey: Offering.OFFERING_CONSUMPTION_KEY)
            offeringDict.updateValue(description as AnyObject, forKey: Offering.OFFERING_DESCRIPTION_KEY)
            offeringDict.updateValue(fuel as AnyObject, forKey: Offering.OFFERING_FUEL_ID_KEY)
            offeringDict.updateValue(gear as AnyObject, forKey: Offering.OFFERING_GEAR_ID_KEY)
            offeringDict.updateValue(speed as AnyObject, forKey: Offering.OFFERING_HP_KEY)
            offeringDict.updateValue(latitute as AnyObject, forKey:  Offering.OFFERING_LATITUDE_KEY)
            offeringDict.updateValue(location as AnyObject, forKey: Offering.OFFERING_LOCATION_KEY)
            offeringDict.updateValue(longitute as AnyObject, forKey: Offering.OFFERING_LONGITUDE_KEY)
            offeringDict.updateValue(imgURL as AnyObject, forKey: Offering.OFFERING_PICTURE_URL_KEY)
            offeringDict.updateValue(price as AnyObject, forKey: Offering.OFFERING_PRICE_KEY)
            offeringDict.updateValue(seats as AnyObject, forKey: Offering.OFFERING_SEATS_KEY)
            offeringDict.updateValue(carName as AnyObject, forKey: Offering.OFFERING_TYPE_KEY)
            offeringDict.updateValue(user as AnyObject, forKey: Offering.OFFERING_USER_UID_KEY)
            offeringDict.updateValue(vehicleType as AnyObject, forKey: Offering.OFFERING_VEHICLE_TYPE_ID_KEY)
            offeringDict.updateValue(pickupTime as AnyObject, forKey: Offering.OFFERING_PICKUP_TIME_KEY)
            offeringDict.updateValue(returnTime as AnyObject, forKey: Offering.OFFERING_RETURN_TIME_KEY)
        } else {
        }
        return offeringDict
    }
    
    func releaseDate(date: Date){
        if blockedDates.count > 0 {
            if let index = blockedDates.index(of: date) {
                blockedDates.remove(at: index)
            }
        }
    }
        

    
}
