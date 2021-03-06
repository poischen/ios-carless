//
//  DBConstants.swift
//  ios
//
//  Created by Konrad Fischer on 03.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class DBConstants {
    static let PROPERTY_NAME_OFFERINGS = "inserat"
    static let PROPERTY_NAME_RENTINGS = "renting"
    static let PROPERTY_NAME_FEATURES = "features"
    static let PROPERTY_NAME_OFFERINGS_FEATURES = "inserat_features"
    static let PROPERTY_NAME_VEHICLE_TYPES = "types"
    static let PROPERTY_NAME_GEARS = "gear"
    static let PROPERTY_NAME_BRANDS = "brands"
    static let PROPERTY_NAME_FUELS = "fuel"
    static let PROPERTY_NAME_RATINGS = "ratings"
    
    // constants for offering's features as they don't have their own class
    static let PROPERTY_NAME_OFFERINGS_FEATURES_FEATURE = "feature"
    static let PROPERTY_NAME_OFFERINGS_FEATURES_OFFERING = "inserat"
    static let PROPERTY_NAME_OFFERINGS_AVAILIBILITY = "availibility_blocked"
    static let PROPERTY_NAME_OFFERINGS_BLOCKED = "blocked_dates"
    
    //DBProvider

    static let IMAGE_STORAGE_OFFER = "Image_Storage/offers";
    static let IMAGE_STORAGE_PROFILE = "Image_Storage/profile_pictures";
    static let USERS = "Users"
    static let MESSAGES = "messages"
    static let USER_MESSAGES = "user-messages"
    static let MEDIA_MESSAGES = "media_Messages"
    static let IMAGE_STORAGE = "Image_Storage"
    static let VIDEO_STORAGE = "Video_Storage"
    
    static let NAME = "name"
    static let EMAIL = "email"
    static let PASSWORD = "password"
    static let DATA = "data"
    static let RATING = "rating"
    static let PROFILEIMG = "profileImg"
    static let DEVICE_TOKEN = "device-id"
    
    //messages
    static let TEXT = "text"
    static let SENDER_ID = "sender_id"
    static let SENDER_NAME = "sender_name"
    static let RECEIVER_ID = "receiver_id"
    static let URL = "url"
}
