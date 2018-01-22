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
    let maxDistanceFromNow:Double = 30 * 24 * 3600 // one month
    let rateableAfter:Double = 2 * 24 * 3600 // 2 days
    
    init(){
        storageAPI = StorageAPI.shared
    }
    
    /* func getUsersRentings(UID: String, completion: @escaping (_ data: [(Renting, Offering, Brand)]) -> Void) {
        var result:[(Renting, Offering, Brand)] = []
        storageAPI.getRentingsByUserUID(userUID: UID, completion: {rentings in
            let numberOfRentings = rentings.count
            // TODO: will the rentings appear in a deterministic order?
            // TODO: handle errors
            for renting in rentings {
                self.storageAPI.getOfferingWithBrandByOfferingID(offeringID: renting.inseratID, completion: {(offering,offeringsBrand) in
                    result.append((renting, offering, offeringsBrand))
                    if (result.count == numberOfRentings) {
                        completion(result)
                    }
                })
            }
        })
    } */
    
    func subscribeToUsersRentings(UID: String, completion: @escaping (_ data: [(Renting, Offering, Brand, Bool)]) -> Void) {
        storageAPI.subscribeToUsersRentings(userUID: UID, completion: {rentings in
            var result:[(Renting, Offering, Brand, Bool)] = []
            
            let newerRentings = rentings.filter {renting in
                if (renting.endDate < Date()){
                    // renting has already ended -> check how long ago it ended
                    let distanceFromNow = DateInterval(start: renting.endDate, end: Date())
                    if (distanceFromNow.duration < self.maxDistanceFromNow) {
                        // renting is "new enough" -> show
                        return true
                    } else {
                        // renting is too old -> hide
                        return false
                    }
                } else {
                    // renting hasn't ended yet -> show
                    return true
                }
            }
            
            
            let numberOfRentings = newerRentings.count
            // TODO: will the rentings appear in a deterministic order?
            // TODO: handle errors
            if numberOfRentings == 0 {
                // empty array should also fire callback to pass on that the user has no rentings
                // (can e.g. happen when a renting of the user is denied)
                completion([])
            } else {
                for renting in newerRentings {
                    self.storageAPI.getOfferingWithBrandByOfferingID(offeringID: renting.inseratID, completion: {(offering,offeringsBrand) in
                        // TODO: avoid code duplication
                        let distanceFromNow = DateInterval(start: renting.endDate, end: Date())
                        let rateable = distanceFromNow.duration > self.rateableAfter
                        result.append((renting, offering, offeringsBrand, rateable))
                        if (result.count == numberOfRentings) {
                            completion(result)
                        }
                    })
                }
            }
        })
    }
    func subscribeToUsersOfferings(UID: String, completion: @escaping (_ data: [(Offering, Brand)]) -> Void) {
        // TODO: move into storage API?
        /* var result:[(Offering, Brand)] = []
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
        })*/
        storageAPI.subscribeToUsersOfferingsWithBrands(userUID: UID, completion: completion)
    }
    
    // TODO: more efficient variant?
    // TODO: is it necessary to return the renting?
    /* func getUnconfirmedRequestsForUsersOfferings(UID: String, completion: @escaping (_ data: [(Offering, Brand, User, Renting)]) -> Void){
        var result:[(Offering, Brand, User, Renting)] = []
        var offeringsProcessed = 0
        subscribeToUsersOfferings(UID: UID, completion: {usersOfferings in
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
    } */
    
    // TODO: make this more efficient by only returning the offering once for all requests for that offering
    // TODO: merge with subscribeToUsersOfferings?
    // TODO: Does this method have to handle empty arrays like the others do?
    func subscribeToUnconfirmedRequestsForUsersOfferings(UID: String, completion: @escaping (_ offeringID: String, _ data: [(Offering, Brand, User, Renting)]) -> Void){
        var watchedOfferingsIDs:Set = Set<String>()
        storageAPI.subscribeToUsersOfferingsWithBrands(userUID: UID, completion: {usersOfferings in
            for (offering, brand) in usersOfferings {
                // TODO: find better solution for offeringID here
                if (offering.id != nil && (!watchedOfferingsIDs.contains(offering.id!))){
                    // offering has an ID and is not watched yet -> add it to the watched offerings and create listener for this offering
                    watchedOfferingsIDs.insert(offering.id!)
                    self.storageAPI.subscribeToRentingsForOffering(offeringID: offering.id!, completion: {offeringsRentings in
                        // we're only interested in the unconfirmed rentings
                        let unconfirmedRentings = offeringsRentings.filter {$0.confirmationStatus == false}
                        var resultsForThisOffering:[(Offering, Brand, User, Renting)] = []
                        if (unconfirmedRentings.count > 0) {
                            // unconfirmed rentings exist -> proceed with them
                            for unconfirmedRenting in unconfirmedRentings {
                                self.storageAPI.getUserByUID(UID: unconfirmedRenting.userID, completion: {rentingUser in
                                    resultsForThisOffering.append((offering, brand, rentingUser, unconfirmedRenting))
                                    if (resultsForThisOffering.count == unconfirmedRentings.count) {
                                        // all unconfirmed rentings for this offering processed -> offering processed -> fire callback
                                        completion(offering.id!, resultsForThisOffering)
                                    }
                                })
                            }
                        } else {
                            // no unconfirmed ratings exists -> fire callback
                            // this is necessary to make accepted requests disappear
                            completion(offering.id!, [])
                        }
                    })
                }
            }
        })
    }
    
    func acceptRenting(renting: Renting) {
        renting.confirmationStatus = true
        storageAPI.updateRenting(renting: renting)
    }
    
    func denyRenting(renting: Renting){
        if let rentingID = renting.id {
            storageAPI.deleteRentingByID(rentingID: rentingID)
        }
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
