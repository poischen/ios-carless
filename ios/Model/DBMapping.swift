//
//  DBMapping.swift
//  ios
//
//  Created by Konrad Fischer on 09.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class DBMapping {
    // THIS CLASS IS DEPRECTATED, please use the methods in StorageAPI to get brands, fuels and gears by ID
    
    static let shared = DBMapping()

    // TODO: necessary to store brands here when DB already caches?
    // TODO: use maps here?
    
    let storageAPI = StorageAPI.shared
    var brands:[Int:Brand]? // unsing dictionaries here as the main operation on the brands, gears and fuels will be getting an item that has a certain ID
    var gears:[Int:Gear]?
    var fuels:[Int:Fuel]?
    
    func fillBrandsCache(completion: @escaping () -> Void){
        self.storageAPI.getBrandsAsMap(completion: {brandsMap in
            self.brands = brandsMap
            completion()
        })
    }
    
    func fillGearsCache(completion: () -> Void){
        self.storageAPI.getGearsAsMap(completion: {gearsMap in
            self.gears = gearsMap
        })
        completion()
    }
    
    func fillFuelsCache(completion: @escaping () -> Void){
        self.storageAPI.getFuelsAsMap(completion: {fuelsMap in
            self.fuels = fuelsMap
            completion()
        })
    }
        
    func mapBrandIDToBrand(id: Int) ->  Brand? {
        if let brands = self.brands {
            if let matchingBrand = brands[id] {
                return matchingBrand
            } else {
                // returns nil if no brand has been found
                return nil
            }
        } else {
            // return nil as long as the brands variable hasn't been filled
            return nil
        }
    }
    
    func mapGearIDToGear(id: Int) ->  Gear? {
        if let gears = self.gears {
            if let matchingGear = gears[id] {
                return matchingGear
            } else {
                // returns nil if no gear has been found
                return nil
            }
        } else {
            // return nil as long as the gears variable hasn't been filled
            return nil
        }
    }
    
    func mapFuelIDToFuel(id: Int) ->  Fuel? {
        if let fuels = self.fuels {
            if let matchingFuel = fuels[id] {
                return matchingFuel
            } else {
                // returns nil if no fuel has been found
                return nil
            }
        } else {
            // return nil as long as the fuels variable hasn't been filled
            return nil
        }
    }
    
    /*
     not using this version as I thought there's no way to be sure when the callback in the cell rendering method will fire
     it could be after the function has finished running and I don't know whether changing a cell's value after returning it will have any effect O:-)
     But it looks like I was wrong, trying this again soon. */
     
    /*func getFilteredOfferingsWithExtraInfo(filter: Filter, completion: @escaping (_ offerings: [Offering]) -> Void) {
        let searchModel = SearchModel()
        searchModel.getFilteredOfferings(filter: filter, completion: {offerings in
            
        })
    }*/
}
