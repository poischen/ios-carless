//
//  Time.swift
//  ios
//
//  Created by Konrad Fischer on 24.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Time {
    static let TIME_SEPARATOR = ":"
    
    let minutes: Int
    let hours: Int
    
    init? (timestring: String){
        let timestringComponents = timestring.components(separatedBy: Time.TIME_SEPARATOR)
        if timestringComponents.count == 2 {
            if let minutes = Int(timestringComponents[0]), let hours = Int(timestringComponents[1]){
                self.minutes = minutes
                self.hours = hours
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
