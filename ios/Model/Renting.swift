//
//  Renting.swift
//  ios
//
//  Created by Konrad Fischer on 02.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Renting: DictionaryConvertible {
    
    // constants for the dictionary keys
    static let RENTING_END_TIMESTAMP_KEY = "endDate"
    static let RENTING_OFFERING_ID_KEY = "inseratId"
    static let RENTING_START_TIMESTAMP_KEY = "startDate"
    static let RENTING_USER_ID_KEY = "userId"
    
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let rentingEndDateTimestamp = dict[Renting.RENTING_END_TIMESTAMP_KEY] as? Int,
              let rentingInseratID = dict[Renting.RENTING_OFFERING_ID_KEY] as? Int,
              let rentingStartDateTimestamp = dict[Renting.RENTING_START_TIMESTAMP_KEY] as? Int,
              let rentingUserId = dict[Renting.RENTING_USER_ID_KEY] as? String else {
            return nil
        }
        let startDate = Renting.intTimestampToDate(timestamp: rentingStartDateTimestamp)
        let endDate = Renting.intTimestampToDate(timestamp: rentingEndDateTimestamp)
        self.init(id: id, inseratID: rentingInseratID, userID: rentingUserId, startDate: startDate, endDate: endDate)
    }
    
    var dict: [String : AnyObject] {
        return [
            Renting.RENTING_END_TIMESTAMP_KEY: Renting.dateToIntTimestamp(date: self.endDate) as AnyObject,
            Renting.RENTING_OFFERING_ID_KEY: self.inseratID as AnyObject,
            Renting.RENTING_START_TIMESTAMP_KEY: Renting.dateToIntTimestamp(date: self.startDate) as AnyObject,
            Renting.RENTING_USER_ID_KEY: self.userID as AnyObject
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
