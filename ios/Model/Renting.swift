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
        guard let rentingEndDateTimestamp = dict["endDate"] as? Int,
              let rentingInseratID = dict["inseratId"] as? Int,
              let rentingStartDateTimestamp = dict["startDate"] as? Int,
              let rentingUserId = dict["userId"] as? String else {
            return nil
        }
        let startDate = Renting.intTimestampToDate(timestamp: rentingStartDateTimestamp)
        let endDate = Renting.intTimestampToDate(timestamp: rentingEndDateTimestamp)
        self.init(id: id, inseratID: rentingInseratID, userID: rentingUserId, startDate: startDate, endDate: endDate)
    }
    
    var dict: [String : AnyObject] {
        return [
            "endDate": Renting.dateToIntTimestamp(date: self.endDate) as AnyObject,
            "inseratId": self.inseratID as AnyObject,
            "startDate": Renting.dateToIntTimestamp(date: self.startDate) as AnyObject,
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
    
    static func intTimestampToDate(timestamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    static func dateToIntTimestamp(date: Date) -> Int {
        return Int(date.timeIntervalSince1970)
    }
}
