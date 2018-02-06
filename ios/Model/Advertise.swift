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
    let seatsPickerContent = ["1", "2", "3", "4", "5", "6", "7", "8", "more"]
    let seatsPickerIcons = [UIImage(named:"1"), UIImage(named:"2"), UIImage(named:"3"), UIImage(named:"4"), UIImage(named:"5"), UIImage(named:"6"), UIImage(named:"7"), UIImage(named:"8"), UIImage(named:"9")]
    
    
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
            brandsDict.updateValue(brand.id, forKey: brandName)
            brandsPickerContent.append(brandName)
        }
    }
    
    func receiveFuels(fuels: [Fuel]) -> Void {
        self.fuels = fuels
        for fuel in fuels {
            let fuelName = fuel.name
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
            featuresDict.updateValue(feature.id, forKey: featureName)
            
            if let icon = UIImage(named: featureName) {
                featuresImages.append(icon)
                featuresLabels.append(featureName)
            } else {
                let url = URL(string: feature.iconURL)!
                KingfisherManager.shared.retrieveImage(with: url, options: nil, progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                    self.featuresLabels.append(featureName)
                    self.featuresImages.append(image!)
                })
            }
        }
    }

}
