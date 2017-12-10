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
    var brands: [Brand]?
    
    func mapBrandIDToName(brandID: Int) -> String {
        /* if let brands = self.brands {
            
        } else {
            storageAPI.getBrands(completion: {brands in
                self.brands = brands
                let resultBrand:Brand = self.brands.filter {$0.id == brandID}[0]
                return resultBrand.name
            })
        } */
        return "test"
    }
}
