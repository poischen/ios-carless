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
    
    init(brandIDs: [Int]?, maxConsumption: Int?, fuelIDs: [Int]?, gearIDs: [Int]?, minHP: Int?, location: String?, maxPrice: Int?, minSeats: Int?, vehicleTypeIDs: [Int]?, startDateRaw: Date?, endDateRaw: Date?, featureIDs: [Int]?) {
        self.brandIDs = brandIDs
        self.maxConsumption = maxConsumption
        self.fuelIDs = fuelIDs
        self.gearIDs = gearIDs
        self.minHP = minHP
        self.location = location
        self.maxPrice = maxPrice
        self.minSeats = minSeats
        self.vehicleTypeIDs = vehicleTypeIDs
        if let startDate = startDateRaw, let endDate = endDateRaw {
            self.dateInterval = DateInterval(start: self.dateTo30(date: startDate), end: self.dateTo30(date: endDate))
        }
        self.featureIDs = featureIDs
    }
    
    func dateTo30(date: Date) -> Date{
        var editedDate = date
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        //var secondsToAdd = 0
        /* if (minutes > 0 && minutes < 30){
         secondsToAdd =
         } */
        if (minutes != 60 && minutes != 30){
            let secondsToAdd = (60*(30-(minutes % 30)))
            editedDate = date + Double(secondsToAdd)
        }
        // remove seconds
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: editedDate)
        editedDate = calendar.date(from: components)!
        return editedDate
    }
}
