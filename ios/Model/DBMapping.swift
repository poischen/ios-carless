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
    
    func fillBrandCache(completion: () -> Void){
        self.storageAPI.getBrands(completion: {brands in
            self.brands = brands
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
}
