//
//  User.swift
//  ios
//
//  Created by Jelena Pranjic on 29.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation
//TODO: Implement interface?!
class User {
    required convenience init?(id: String, dict: [String : AnyObject]) {
        guard let userName = dict[User.NAME] as? String,
            let userEmail = dict[User.EMAIL] as? String,
            let userRating = dict[User.RATING] as? Float,
            let profileImg = dict[User.PROFILEIMG] as? String,
            let numberOfRatings = dict[User.NUMBER_OF_RATINGS] as? Int, let deviceID = dict[User.DEVICE_TOKEN] as? String else {
                return nil
        }
        self.init(id: id, name: userName, email: userEmail, rating: userRating, profileImgUrl: profileImg, numberOfRatings: numberOfRatings, deviceID: deviceID )
    }
    
    
    static let NAME = "name"
    static let EMAIL = "email"
    static let RATING = "rating"
    static let PROFILEIMG = "profileImg"
    static let NUMBER_OF_RATINGS = "numberOfRatings"
    static let DEVICE_TOKEN = "device-id"
    
    
    let name: String
    let id: String
    let email: String
    var rating: Float
    let profileImgUrl: String
    var numberOfRatings: Int
    let deviceID: String
    
    init(id: String, name: String, email: String, rating: Float, profileImgUrl: String, numberOfRatings: Int, deviceID: String){
        self.id = id
        self.name = name
        self.email = email
        self.rating = rating
        self.profileImgUrl = profileImgUrl
        self.numberOfRatings = numberOfRatings
        self.deviceID = deviceID
        
    }
    
    var dict: [String : AnyObject] {
        return [
            User.NAME: self.name as AnyObject,
            User.EMAIL: self.email as AnyObject,
            User.RATING: self.rating as AnyObject,
            User.PROFILEIMG: self.profileImgUrl as AnyObject,
            User.NUMBER_OF_RATINGS: self.numberOfRatings as AnyObject,
            User.DEVICE_TOKEN: self.deviceID as AnyObject
            
        ]
    }
    
}
