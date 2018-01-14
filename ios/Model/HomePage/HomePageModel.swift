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
    
    // TODO: more efficient variant?
    // TODO: is it necessary to return the renting?
    func getUnconfirmedOfferingsForUsersOfferings(UID: String, completion: @escaping (_ data: [(Offering, Brand, User, Renting)]) -> Void){
        var result:[(Offering, Brand, User, Renting)] = []
        var offeringsProcessed = 0
        getUsersOfferings(UID: UID, completion: {usersOfferings in
            for (offering, brand) in usersOfferings {
                if let offeringID = offering.id {
                    self.storageAPI.getRentingsByOfferingID(offeringID: offeringID, completion: {offeringsRentings in
                        // we're only interested in the unconfirmed rentings
                        let unconfirmedRentings = offeringsRentings.filter {$0.confirmationStatus == false}
                        var resultsForThisOffering:[(Offering, Brand, User, Renting)] = []
                        if (unconfirmedRentings.count > 0) {
                            // unconfirmed offerings exist -> proceed with them
                            for unconfirmedRenting in unconfirmedRentings {
                                self.storageAPI.getUserByUID(UID: unconfirmedRenting.userID, completion: {rentingUser in
                                    resultsForThisOffering.append((offering, brand, rentingUser, unconfirmedRenting))
                                    if (resultsForThisOffering.count == unconfirmedRentings.count) {
                                        // all unconfirmed rentings for this offering processed -> offering processed -> add results to total results
                                        offeringsProcessed = offeringsProcessed + 1
                                        result.append(contentsOf: resultsForThisOffering)
                                        if (offeringsProcessed == usersOfferings.count) {
                                            completion(result)
                                        }
                                    }
                                })
                            }
                        } else {
                            // no unconfirmed offerings exist -> offering processed
                            offeringsProcessed = offeringsProcessed + 1
                            if (offeringsProcessed == usersOfferings.count) {
                                completion(result)
                            }
                        }
                    })
                }
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
    
    // TODO: move somewhere else?
    func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
}
