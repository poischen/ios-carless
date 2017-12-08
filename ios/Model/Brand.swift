//
//  Brand.swift
//  ios
//
//  Created by Konrad Fischer on 21.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Brand: DictionaryConvertible {
    typealias convertTo = Brand
    static func dictionaryToArray(dictionary: NSDictionary) -> [Brand] {
        var resultBrands:[Brand] = []
        for (brandIDRaw, brandDataRaw) in dictionary {
            if let brandData:NSDictionary = brandDataRaw as? NSDictionary {
                guard let brandName = brandData["brand"] as? String,
                    let brandIDString:String = brandIDRaw as? String else {
                    print("invalid brandName or brandID in Brand")
                    return []
                }
                let newBrand:Brand = Brand(id: Int(brandIDString)!, name: brandName)
                resultBrands.append(newBrand)
            } else {
                print("invalid brandData in Brand")
                return []
            }
        }
        return resultBrands
    }
    
    let id: Int
    let name: String
    var isSelected: Bool
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.isSelected = false
    }
    
    func toggleSelected() {
        self.isSelected = !self.isSelected
    }
}
