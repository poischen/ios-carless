//
//  HomePageModel.swift
//  ios
//
//  Created by Konrad Fischer on 14.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation

class HomePageModel {
    
    static let shared = HomePageModel();
    
    let storageAPI:StorageAPI
    
    init(){
        storageAPI = StorageAPI.shared
    }
    
    func getUsersRentings(UID: String, completion: @escaping (_ data: [(Renting, Offering, Brand)]) -> Void) {
        var result:[(Renting, Offering, Brand)] = []
        storageAPI.getRentingsByUserUID(userUID: UID, completion: {rentings in
            let numberOfRentings = rentings.count
            // TODO: will the rentings appear in a deterministic order?
            // TODO: handle errors
            // TODO: avoid code duplication
            for renting in rentings {
                self.storageAPI.getOfferingWithBrandByOfferingID(offeringID: renting.inseratID, completion: {(offering,offeringsBrand) in
                    result.append((renting, offering, offeringsBrand))
                    if (result.count == numberOfRentings) {
                        completion(result)
                    }
                })
            }
        })
    }
    
    func getUsersOfferings(UID: String, completion: @escaping (_ data: [(Offering, Brand)]) -> Void) {
        // TODO: move into storage API?
        var result:[(Offering, Brand)] = []
        storageAPI.getOfferingsByUserUID(userUID: UID, completion: {offerings in
            let numberOfOfferings = offerings.count
            for offering in offerings {
                self.storageAPI.getBrandByID(id: offering.brandID, completion: {offeringsBrand in
                    result.append((offering, offeringsBrand))
                    if (result.count == numberOfOfferings) {
                        completion(result)
                    }
                })
            }
        })
    }

    
    /*
     old version with caching of offerings:
     func getUsersRentings(UID: String, completion: @escaping (_ data: [(Renting, Offering)]) -> Void) {
     var offeringsCache:[String:Offering] = [:]
     var result:[(Renting, Offering)] = []
     storageAPI.getRentingsByUserUID(userUID: UID, completion: {rentings in
     let numberOfRentings = rentings.count
     // TODO: will the rentings appear in a deterministic order?
     // TODO: handle errors
     // TODO: avoid code duplication
     for renting in rentings {
     if let cachedOffering = offeringsCache[renting.inseratID] {
     result.append((renting, cachedOffering))
     if (result.count == numberOfRentings) {
     completion(result)
     }
     } else {
     self.storageAPI.getOfferingByID(id: renting.inseratID, completion: {offering in
     offeringsCache[renting.inseratID] = offering
     result.append((renting, offering))
     if (result.count == numberOfRentings) {
     completion(result)
     }
     })
     
     }
     }
     })
     }
 */
    
    func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
}
