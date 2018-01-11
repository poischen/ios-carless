//
//  Time.swift
//  ios
//
//  Created by Konrad Fischer on 24.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

// represents a time of day in 24 hour format

class Time {
    static let TIME_SEPARATOR = ":"
    
    let minutes: Int
    let hours: Int
    
    // construct time of day from timestring
    init? (timestring: String){
        // split timestring
        let timestringComponents = timestring.components(separatedBy: Time.TIME_SEPARATOR)
        if timestringComponents.count == 2 {
            if let minutes = Int(timestringComponents[0]), let hours = Int(timestringComponents[1]){
                // minutes and hours exist in timestring -> initialise values -> done
                self.minutes = minutes
                self.hours = hours
            } else {
                // timestring has the wrong format
                return nil
            }
        } else {
            // timestring has the wrong format (e.g. "XX:")
            return nil
        }
    }
    
    // checks whether the time of day of a date is earlier or equal to the time of day represented by this object
    func timeOfDayIsEarlierOrEqual(date: Date) -> Bool {
        let calendar = Calendar.current
        let dateHour = calendar.component(.hour, from: date) // get hours from date to compare to
        let dateMinutes = calendar.component(.minute, from: date) // get minutes from date to compare to
        return (dateHour <= self.hours && dateMinutes <= self.minutes)
    }
}
