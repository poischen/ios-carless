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
    
    // "rounds" a date to the next XX:30 time of day (removes seconds in this process)
    static func dateToNext30(date: Date) -> Date{
        var editedDate = date
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        if (minutes != 00 && minutes != 30){
            // only round if time isn't already XX:00 or XX:30
            let secondsToAdd = (60*(30-(minutes % 30))) // add seconds to fill to XX:00 or XX:30
            editedDate = date + Double(secondsToAdd)
        }
        // remove seconds
        return dateRemoveSeconds(date: editedDate)
    }
    
    // removes the seconds of a date
    static func dateRemoveSeconds(date: Date) -> Date {
        let calendar = Calendar.current
        // parse date into components, but don't parse seconds
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        // create date from components without seconds -> seconds will be "00" in the new date
        return calendar.date(from: components)!
    }
    
    // merges two dates: takes the day from the first one and the time (hour and minute) from the second one
    static func mergeDates(dayDate: Date, hoursMinutesDate: Date) -> Date{
        let calendar = Calendar.current
        let dayDateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: dayDate) // parse day date, as no seconds are parsed the returned date will have "00" as value in the seconds attribute
        let hoursMinutesDateComponents = calendar.dateComponents([.hour, .minute], from: hoursMinutesDate) // parse hours minutes date but only parse hours and minutes
        // construct new date and ...
        var mergedDateComponents = DateComponents()
        // ... set the day to the day of the day date ...
        mergedDateComponents.year = dayDateComponents.year
        mergedDateComponents.month = dayDateComponents.month
        mergedDateComponents.day = dayDateComponents.day
        // ... and set the time to the time of the hoursMinutes date
        mergedDateComponents.hour = hoursMinutesDateComponents.hour
        mergedDateComponents.minute = hoursMinutesDateComponents.minute
        return calendar.date(from: mergedDateComponents)! // forcing optional unwrap as contstructing a date from components of dates should always work
    }
}
