//
//  Filter.swift
//  ios
//
//  Created by Konrad Fischer on 17.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Filter {
    var brandIDs: [Int]?
    var maxConsumption: Int?
    var fuelIDs: [Int]?
    var gearIDs: [Int]?
    var minHP: Int?
    var location: String?
    var maxPrice: Int?
    var minSeats: Int?
    var vehicleTypeIDs: [Int]?
    var dateInterval: DateInterval?
    var featureIDs: [Int]?
    
    init(brandIDs: [Int]?, maxConsumption: Int?, fuelIDs: [Int]?, gearIDs: [Int]?, minHP: Int?, location: String?, maxPrice: Int?, minSeats: Int?, vehicleTypeIDs: [Int]?, dateInterval: DateInterval?, featureIDs: [Int]?) {
        self.brandIDs = brandIDs
        self.maxConsumption = maxConsumption
        self.fuelIDs = fuelIDs
        self.gearIDs = gearIDs
        self.minHP = minHP
        self.location = location
        self.maxPrice = maxPrice
        self.minSeats = minSeats
        self.vehicleTypeIDs = vehicleTypeIDs
        self.dateInterval = dateInterval
        self.featureIDs = featureIDs
    }
    
    // HELPER FUNCTIONS
    
    // TODO: remove, not needed anymore
    static func dateToNext30(date: Date) -> Date{
        var editedDate = date
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        if (minutes != 60 && minutes != 30){
            let secondsToAdd = (60*(30-(minutes % 30)))
            editedDate = date + Double(secondsToAdd)
        }
        // remove seconds
        return dateRemoveSeconds(date: editedDate)
    }
    
    static func dateRemoveSeconds(date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        return calendar.date(from: components)!
    }
    
    static func setDatesHoursMinutes(originalDate: Date, hoursMinutesDate: Date) -> Date{
        let calendar = Calendar.current
        let originalDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: originalDate) // as no seconds are parsed the returned date will have "00" as value in the seconds attribute
        let hoursMinutesDateComponents = calendar.dateComponents([.hour, .minute], from: hoursMinutesDate)
        var mergedDateComponents = DateComponents()
        mergedDateComponents.year = originalDateComponents.year
        mergedDateComponents.month = originalDateComponents.month
        mergedDateComponents.day = originalDateComponents.day
        mergedDateComponents.hour = hoursMinutesDateComponents.hour
        mergedDateComponents.minute = hoursMinutesDateComponents.minute
        return calendar.date(from: mergedDateComponents)! // forcing optional unwrap as contstructing a date from components of dates should always work
    }
}
