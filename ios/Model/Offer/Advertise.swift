//
//  Advertise.swift
//  ios
//
//  Created by admin on 05.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

/*
 * Provides all data needed to advertise a vehicle
 */

final class Advertise {
    
    let storageAPI = StorageAPI.shared
    static let shared = Advertise()
    
    //constants for conversion input to id
    static let ADVERTISE_CONVERSION_BRANDS = "brands"
    static let ADVERTISE_CONVERSION_FUELS = "fuels"
    static let ADVERTISE_CONVERSION_GEARS = "gears"
    static let ADVERTISE_CONVERSION_VEHICLETYPES = "vehicleTypes"
    static let ADVERTISE_CONVERSION_FEATURES = "features"
    static let ADVERTISE_CONVERSION_SEATS = "seats"
    
    //values from DB
    var brands: [Brand]?
    var fuels: [Fuel]?
    var gears: [Gear]?
    var vehicleTypes: [VehicleType]?
    var features: [Feature]?

/*
    //storing objects for easy access to id and iconURL via item name as key
    var brandsDict: [String : AnyObject] = [:]
    var fuelsDict: [String : AnyObject] = [:]
    var gearsDict: [String : AnyObject] = [:]
    var vehicleTypesDict: [String : AnyObject] = [:]
    var featuresDict: [String : AnyObject] = [:]
 */
    
    //storing objects for easy access to id via item name as key
    var brandsDict: [String : Int] = [:]
    var fuelsDict: [String : Int] = [:]
    var gearsDict: [String : Int] = [:]
    var vehicleTypesDict: [String : Int] = [:]
    var featuresDict: [String : Int] = [:]

    //necessary values vor input UI
    var brandsPickerContent: [String] = []
    var fuelPickerContent: [String] = []
    var gearPickerContent: [String] = []
    var vehicleTypeContent: [String] = []
    
    //var brandsPickerIcons: [UIImage] = []
    var fuelPickerIcons: [UIImage] = []
    var gearPickerIcons: [UIImage] = []
    var vehicleTypeIcons: [UIImage] = []
    
    var featuresImages: [UIImage]  = []
    var featuresLabels: [String]  = []
    
    //further values vor input UI
    var seatsPickerContent = ["1", "2", "3", "4", "5", "6", "7", "8", "more"]
    var seatsPickerIcons = [UIImage(named:"1"), UIImage(named:"2"), UIImage(named:"3"), UIImage(named:"4"), UIImage(named:"5"), UIImage(named:"6"), UIImage(named:"7"), UIImage(named:"8"), UIImage(named:"9")]
    var timeContent = ["00:00", "00:30", "01:00", "01:30", "02:00", "02:30", "03:00", "03:30", "04:00", "04:30", "05:00", "05:30", "06:00", "06:30", "07:00", "07:30", "08:00", "08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30", "18:00", "18:30", "19:00", "19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30"]
    
    
    init(){
        storageAPI.getBrands(completion: receiveBrands)
        storageAPI.getFuels(completion: receiveFuels)
        storageAPI.getGears(completion: receiveGears)
        storageAPI.getVehicleTypes(completion: receiveVehicleTypes)
        storageAPI.getFeatures(completion: receiveFeatures)
    }
    
    //receive data from db and convert them to necessary data for input ui
    func receiveBrands(brands: [Brand]) -> Void {
        self.brands = brands
        for brand in brands {
            let brandName = brand.name
            //brandsDict.updateValue(brand, forKey: brandName)
            brandsDict.updateValue(brand.id, forKey: brandName)
            brandsPickerContent.append(brandName)
            
            //let icon = UIImage(named: brandName)
            //brandsPickerIcons.append(icon!)
        }
    }
    
    func receiveFuels(fuels: [Fuel]) -> Void {
        self.fuels = fuels
        for fuel in fuels {
            let fuelName = fuel.name
            //fuelsDict.updateValue(fuel, forKey: fuelName)
            fuelsDict.updateValue(fuel.id, forKey: fuelName)
            fuelPickerContent.append(fuelName)
            
            if let icon = UIImage(named: fuelName) {
                fuelPickerIcons.append(icon)
            } else {
                let url = URL(string: fuel.iconURL)!
                KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                    self.fuelPickerIcons.append(image!)
                })
            }
        }
    }
    
    func receiveGears(gears: [Gear]) -> Void {
        self.gears = gears
        for gear in gears {
            let gearName = gear.name
            //gearsDict.updateValue(gear, forKey: gearName)
            gearsDict.updateValue(gear.id, forKey: gearName)
            gearPickerContent.append(gearName)
            
            if let icon = UIImage(named: gearName) {
                gearPickerIcons.append(icon)
            } else {
                let url = URL(string: gear.iconURL)!
                KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                    self.gearPickerIcons.append(image!)
                })
            }
        }
    }
    
    func receiveVehicleTypes(vehicleTypes: [VehicleType]) -> Void {
        self.vehicleTypes = vehicleTypes
        for vehicleType in vehicleTypes {
            let vehicleTypeName = vehicleType.name
            //vehicleTypesDict.updateValue(vehicleType, forKey: vehicleTypeName)
            vehicleTypesDict.updateValue(vehicleType.id, forKey: vehicleTypeName)
            vehicleTypeContent.append(vehicleTypeName)
            
            if let icon = UIImage(named: vehicleTypeName) {
                vehicleTypeIcons.append(icon)
            } else {
                let url = URL(string: vehicleType.iconURL)!
                KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                    self.vehicleTypeIcons.append(image!)
                })
            }
        }
    }
    
    func receiveFeatures(features: [Feature]) -> Void {
        self.features = features
        for feature in features {
            let featureName = feature.name
            //featuresDict.updateValue(feature, forKey: featureName)
            featuresDict.updateValue(feature.id, forKey: featureName)
            featuresLabels.append(featureName)
            
            if let icon = UIImage(named: featureName) {
                featuresImages.append(icon)
            } else {
                let url = URL(string: feature.iconURL)!
                KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                    self.featuresImages.append(image!)
                })
            }
        }
    }

}
