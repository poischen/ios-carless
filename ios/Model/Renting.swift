//
//  Renting.swift
//  ios
//
//  Created by Konrad Fischer on 02.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Renting: DictionaryConvertibleEditable {
    
    // constants for the dictionary keys
    static let RENTING_END_TIMESTAMP_KEY = "endDate"
    static let RENTING_OFFERING_ID_KEY = "inseratId"
    static let RENTING_START_TIMESTAMP_KEY = "startDate"
    static let RENTING_USER_ID_KEY = "userId"
    static let RENTING_CONFIRMATION_STATUS_KEY = "isConfirmed"
    static let RENTING_PRICE_KEY = "totalPrice"
    static let RENTING_LESSOR_RATED_KEY = "lessorRated"
    static let RENTING_LESSEE_RATED_KEY = "lesseeRated"
    
    convenience required init?(id: String?, dict: [String : AnyObject]) {
        guard let rentingEndDateTimestamp = dict[Renting.RENTING_END_TIMESTAMP_KEY] as? Int,
              let rentingInseratID = dict[Renting.RENTING_OFFERING_ID_KEY] as? String,
              let rentingStartDateTimestamp = dict[Renting.RENTING_START_TIMESTAMP_KEY] as? Int,
              let rentingUserId = dict[Renting.RENTING_USER_ID_KEY] as? String,
              let rentingConfirmationStatus = dict[Renting.RENTING_CONFIRMATION_STATUS_KEY] as? Bool,
              let rentingPrice = dict[Renting.RENTING_PRICE_KEY] as? Float,
              let rentingLessorRated = dict[Renting.RENTING_LESSOR_RATED_KEY] as? Bool,
              let rentingLesseeRated = dict[Renting.RENTING_LESSEE_RATED_KEY] as? Bool
        else {
            return nil
        }
        let startDate = Renting.intTimestampToDate(timestamp: rentingStartDateTimestamp)
        let endDate = Renting.intTimestampToDate(timestamp: rentingEndDateTimestamp)
        self.init(id: id, inseratID: rentingInseratID, userID: rentingUserId, startDate: startDate, endDate: endDate, confirmationStatus: rentingConfirmationStatus, rentingPrice: rentingPrice, lessorRated: rentingLessorRated, lesseeRated: rentingLesseeRated)
    }
    
    var dict: [String : AnyObject] {
        return [
            Renting.RENTING_END_TIMESTAMP_KEY: Renting.dateToIntTimestamp(date: self.endDate) as AnyObject,
            Renting.RENTING_OFFERING_ID_KEY: self.inseratID as AnyObject,
            Renting.RENTING_START_TIMESTAMP_KEY: Renting.dateToIntTimestamp(date: self.startDate) as AnyObject,
            Renting.RENTING_USER_ID_KEY: self.userID as AnyObject,
            Renting.RENTING_CONFIRMATION_STATUS_KEY: self.confirmationStatus as AnyObject,
            Renting.RENTING_PRICE_KEY: self.rentingPrice as AnyObject,
            Renting.RENTING_LESSEE_RATED_KEY: self.lesseeHasRated as AnyObject,
            Renting.RENTING_LESSOR_RATED_KEY: self.lessorHasRated as AnyObject
        ]
    }
    
    var id: String?
    let endDate: Date
    let startDate: Date
    let userID: String
    let inseratID: String
    var confirmationStatus: Bool
    let rentingPrice : Float
    var lessorHasRated: Bool // has to be changed after rating a renting
    var lesseeHasRated: Bool // has to be changed after rating a renting
    
    init(id: String?, inseratID: String, userID: String, startDate: Date, endDate: Date, confirmationStatus: Bool, rentingPrice: Float, lessorRated: Bool, lesseeRated: Bool) {
        self.id = id
        self.inseratID = inseratID
        self.userID = userID
        self.startDate = startDate
        self.endDate = endDate
        self.confirmationStatus = confirmationStatus
        self.rentingPrice = rentingPrice
        self.lessorHasRated = lessorRated
        self.lesseeHasRated = lesseeRated
        
    }
    
    static func intTimestampToDate(timestamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    static func dateToIntTimestamp(date: Date) -> Int {
        return Int(date.timeIntervalSince1970)
    }
}
