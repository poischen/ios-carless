//
//  DBMapping.swift
//  ios
//
//  Created by Konrad Fischer on 09.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class DBMapping {
    static let shared = DBMapping()

    // TODO: necessary to store brands here when DB already caches?
    
    let storageAPI = StorageAPI.shared
    var brands:[Brand]?
    var gears:[Gear]?
    var fuels:[Fuel]?
    
    func fillBrandsCache(completion: () -> Void){
        self.storageAPI.getBrands(completion: {brands in
            self.brands = brands
        })
        completion()
    }
    
    func fillGearsCache(completion: () -> Void){
        self.storageAPI.getGears(completion: {gears in
            self.gears = gears
        })
        completion()
    }
    
    func fillFuelsCache(completion: () -> Void){
        self.storageAPI.getFuels(completion: {fuels in
            self.fuels = fuels
        })
        completion()
    }
        
    func mapBrandIDToBrand(id: Int) ->  Brand? {
        if let brands = self.brands {
            let matchingBrands = brands.filter {$0.id == id}
            if matchingBrands.count == 1 {
                return matchingBrands[0]
            } else {
                // returns nil if more than one or no brand has been found
                return nil
            }
        } else {
            // return nil as long as the brands variable hasn't been filled
            return nil
        }
    }
    
    func mapGearIDToGear(id: Int) ->  Gear? {
        if let gears = self.gears {
            let matchingGears = gears.filter {$0.id == id}
            if matchingGears.count == 1 {
                return matchingGears[0]
            } else {
                // returns nil if more than one or no gear has been found
                return nil
            }
        } else {
            // return nil as long as the gears variable hasn't been filled
            return nil
        }
    }
    
    func mapFuelIDToFuel(id: Int) ->  Fuel? {
        if let fuels = self.fuels {
            let matchingFuels = fuels.filter {$0.id == id}
            if matchingFuels.count == 1 {
                return matchingFuels[0]
            } else {
                // returns nil if more than one or no fuel has been found
                return nil
            }
        } else {
            // return nil as long as the fuels variable hasn't been filled
            return nil
        }
    }
    
    /*
     not using this version as I thought there's no way to be sure when the callback in the cell rendering method will fire
     it could be after the function has finished running and I don't know whether chaning a cell's value after returning it will have any effect O:-)
     
     func mapGearIDToGear(id: Int, completion: @escaping (_ gear: Gear) -> Void) {
        self.storageAPI.getGears(completion: {gears in
            let matchingGears = gears.filter {$0.id == id}
            if matchingGears.count == 1 {
                completion(matchingGears[0])
            }
        })
    } */
}
