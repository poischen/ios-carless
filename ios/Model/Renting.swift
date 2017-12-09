//
//  Renting.swift
//  ios
//
//  Created by Konrad Fischer on 02.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Renting: DictionaryConvertible {
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let rentingEndDateString = dict["endDate"] as? String,
              let rentingInseratID = dict["inseratId"] as? Int,
              let rentingStartDateString = dict["startDate"] as? String,
              let rentingUserId = dict["userId"] as? String else {
            return nil
        }
        if let startDate = Renting.stringToDate(dateString: rentingStartDateString), let endDate = Renting.stringToDate(dateString: rentingEndDateString) {
            self.init(id: id, inseratID: rentingInseratID, userID: rentingUserId, startDate: startDate, endDate: endDate)
        } else {
            return nil
        }
    }
    
    var dict: [String : AnyObject] {
        return [
            "endDate": Renting.dateToString(date: self.endDate) as AnyObject,
            "inseratId": self.inseratID as AnyObject,
            "startDate": Renting.dateToString(date: self.startDate) as AnyObject,
            "userId": self.userID as AnyObject
        ]
    }
    
    let id: Int
    let endDate: Date
    let startDate: Date
    let userID: String
    let inseratID: Int
    
    init(id: Int, inseratID: Int, userID: String, startDate: Date, endDate: Date) {
        self.id = id
        self.inseratID = inseratID
        self.userID = userID
        self.startDate = startDate
        self.endDate = endDate
    }
    
    static func stringToDate(dateString: String) -> Date? {
        var formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        // adding one hour as the date formatter always parses the day before at 11 PM for some reason
        if let parsedDate:Date = formatter.date(from: dateString) {
            return parsedDate + 3600
        } else {
            return nil
        }
    }
    
    static func dateToString(date: Date) -> String {
        var formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }
}
