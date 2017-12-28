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
    static let PROPERTY_NAME_LESSOR_RATINGS = "lessor_ratings"
    
    // constants for offerings
    static let PROPERTY_NAME_OFFERING_PRICE = "price"
    static let PROPERTY_NAME_OFFERING_BRAND = "brand"
    static let PROPERTY_NAME_OFFERING_CONSUMPTION = "consumption"
    static let PROPERTY_NAME_OFFERING_DESCRIPTION = "description"
    static let PROPERTY_NAME_OFFERING_FUEL = "fuel"
    static let PROPERTY_NAME_OFFERING_GEAR = "gear"
    static let PROPERTY_NAME_OFFERING_HORSEPOWER = "hp"
    static let PROPERTY_NAME_OFFERING_LATITUDE = "latitude"
    static let PROPERTY_NAME_OFFERING_LONGITUDE = "longitude"
    static let PROPERTY_NAME_OFFERING_CITY = "location"
    static let PROPERTY_NAME_OFFERING_PICTURE_URL = "picture"
    static let PROPERTY_NAME_OFFERING_SEATS = "seats"
    static let PROPERTY_NAME_OFFERING_TYPE = "type"
    static let PROPERTY_NAME_OFFERING_VEHICLE_TYPE_ID = "vehicleTypeID"
    
    // constants for offering's features
    static let PROPERTY_NAME_OFFERINGS_FEATURES_FEATURE = "feature"
    static let PROPERTY_NAME_OFFERINGS_FEATURES_OFFERING = "feature"
    
    // constants for rentings
    static let PROPERTY_NAME_RENTING_START_DATE = "startDate"
    static let PROPERTY_NAME_RENTING_END_DATE = "endDate"
    static let PROPERTY_NAME_RENTING_USER_ID = "userId"
    static let PROPERTY_NAME_RENTING_OFFERING_ID = "inseratId"
    
    // constants for vehicle types
    static let PROPERTY_NAME_VEHICLE_TYPE_NAME = "type"
    static let PROPERTY_NAME_VEHICLE_TYPE_ICON_URL = "icon_dl"
    
    // constants for features
    static let PRORPERTY_NAME_FEATURE_NAME = "type"
    static let PRORPERTY_NAME_FEATURE_ICON_URL = "icon_dl"
}
