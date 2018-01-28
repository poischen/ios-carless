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
    
    private var userRentingsCache: [RentingEvent] = []
    private var rentingsOfYourCarsCacheDict: [String:[RentingEvent]] = [:] // key: offering's ID, value: rentings
    private var rentingsOfYourCarsCacheArray: [RentingEvent] {
        var result:[RentingEvent] = []
        for (_, rentings) in rentingsOfYourCarsCacheDict {
            result += rentings
        }
        return result
    }
    private var usersRentingRequestsDict: [String:[SomebodyRented]] = [:]
    private var usersRentingRequestsArray: [SomebodyRented] {
        var result:[SomebodyRented] = []
        for (_, requestData) in usersRentingRequestsDict {
            result += requestData
        }
        return result
    }
    
    init(){
        storageAPI = StorageAPI.shared
    }
    
    func isRentingRateable(renting: Renting, ratingUserIsLessor: Bool) -> Bool {
        if (renting.endDate > Date()){
            // renting is in the future -> not rateable
            return false
        } else {
            let distanceFromNow = DateInterval(start: renting.endDate, end: Date())
            let rentingIsConfirmed = renting.confirmationStatus == true
            let rentingIsOldEnough = distanceFromNow.duration > self.rateableAfter
            var userHasAlreadyRatedRenting:Bool
            if (ratingUserIsLessor) {
                userHasAlreadyRatedRenting = renting.lessorHasRated
            } else {
                userHasAlreadyRatedRenting = renting.lesseeHasRated
            }
            return rentingIsConfirmed && rentingIsOldEnough && (!userHasAlreadyRatedRenting)
        }
    }
    
    func subscribeToUsersRentings(UID: String, completion: @escaping (_ data: [YouRented]) -> Void) {
        storageAPI.subscribeToUsersRentings(userUID: UID, completion: {rentings in
            var result:[YouRented] = []
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
            var numberOfRentings = newerRentings.count
            if numberOfRentings == 0 {
                // empty array should also fire callback to pass on that the user has no rentings
                // (can e.g. happen when a renting of the user is denied)
                completion([])
            } else {
                for renting in newerRentings {
                    self.storageAPI.getOfferingWithBrandByOfferingID(offeringID: renting.inseratID, completion: {offeringResult in
                        if let (offering,offeringsBrand) = offeringResult {
                            let rateable = self.isRentingRateable(renting: renting, ratingUserIsLessor: false)
                            let newYouRented = YouRented(renting: renting, offering: offering, brand: offeringsBrand, isRateable: rateable)
                            result.append(newYouRented)
                        } else {
                            // offering not found -> decrease number of offerings needed for completion
                            numberOfRentings = numberOfRentings - 1
                        }
                        if (result.count == numberOfRentings) {
                            // all offerings processed -> fire completion callback
                            completion(result)
                        }
                    })
                }
            }
        })
    }
    
    // IMPORTANT: The completion callback will be fired whenever a request for one of the renting events changes/appears
    func subscribeToRentingEvents(UID: String, completion: @escaping (_ data: [RentingEvent]) -> Void){
        subscribeToUsersRentings(UID: UID, completion: {(currentYouRented:[YouRented]) in
            // overwrite cache
            self.userRentingsCache = currentYouRented
            let mergedCaches = self.userRentingsCache + self.rentingsOfYourCarsCacheArray
            completion(mergedCaches)
        })
        subscribeToConfirmedRentingsForUsersOfferings(UID: UID, completion: {(offeringID, rentings) in
            // add or overwrite rentings for this offering
            if rentings.count > 0 {
                // overwrite (maybe) existing requests for this offering in the map
                self.rentingsOfYourCarsCacheDict[offeringID] = rentings
            } else {
                // remove key from map if no rentings for the offering exist
                self.rentingsOfYourCarsCacheDict.removeValue(forKey: offeringID)
            }
            let mergedCaches = self.userRentingsCache + self.rentingsOfYourCarsCacheArray
            completion(mergedCaches)
        })
    }
    
    func subscribeToUsersOfferings(UID: String, completion: @escaping (_ data: [(Offering, Brand)]) -> Void) {
        storageAPI.subscribeToUsersOfferingsWithBrands(userUID: UID, completion: completion)
    }
    
    // IMPORTANT: The completion callback will be fired whenever a request for one of the offerings changes/appears
    func subscribeToUnconfirmedRequestsForUsersOfferings(UID: String, completion: @escaping (_ data: [SomebodyRented]) -> Void){
        subscribeToRentingsForUsersOfferings(UID: UID, completion: {(offeringID, peopleRented) in
            let unconfirmedRequests = peopleRented.filter {!$0.renting.confirmationStatus}
            
            // operations here will also change the computed property usersRentingRequestsArray which whill then be passed to the completion handler
            if unconfirmedRequests.count > 0 {
                // overwrite (maybe) existing requests for this offering in the map
                self.usersRentingRequestsDict[offeringID] = unconfirmedRequests
            } else {
                // remove key from map if no requests for the offering exist
                self.usersRentingRequestsDict.removeValue(forKey: offeringID)
            }
            completion(self.usersRentingRequestsArray)
        })
    }
    
    func subscribeToConfirmedRentingsForUsersOfferings(UID: String, completion: @escaping (_ offeringID: String, _ data: [SomebodyRented]) -> Void){
        subscribeToRentingsForUsersOfferings(UID: UID, completion: {(offeringID, peopleRented) in
            let unconfirmedRequests = peopleRented.filter {$0.renting.confirmationStatus}
            completion(offeringID, unconfirmedRequests)
        })
    }

    
    // IMPORTANT: The completion callback will be fired individually for each offering.
    func subscribeToRentingsForUsersOfferings(UID: String, completion: @escaping (_ offeringID: String, _ data: [SomebodyRented]) -> Void){
        // offerings being watched for new rentings
        var watchedOfferingsIDs:Set = Set<String>()
        storageAPI.subscribeToUsersOfferingsWithBrands(userUID: UID, completion: {usersOfferings in
            for (offering, brand) in usersOfferings {
                if (offering.id != nil && (!watchedOfferingsIDs.contains(offering.id!))){
                    // offering has an ID and is not watched yet -> add it to the watched offerings and create listener for this offering
                    watchedOfferingsIDs.insert(offering.id!)
                    self.storageAPI.subscribeToRentingsForOffering(offeringID: offering.id!, completion: {offeringsRentings in
                        var resultsForThisOffering:[SomebodyRented] = []
                        if (offeringsRentings.count > 0) {
                            // rentings exist -> proceed with them
                            for renting in offeringsRentings {
                                self.storageAPI.getUserByUID(UID: renting.userID, completion: {rentingUser in
                                    let isRateable = self.isRentingRateable(renting: renting, ratingUserIsLessor: true)
                                    let somebodyRented = SomebodyRented(renting: renting, offering: offering, brand: brand, userThatRented: rentingUser, isRateable: isRateable)
                                    resultsForThisOffering.append(somebodyRented)
                                    if (resultsForThisOffering.count == offeringsRentings.count) {
                                        // all rentings for this offering processed -> offering processed -> fire callback
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
        // send notification (via butler) to user that his renting has been accepted
        MessageHandler.shared.handleSend(senderID: MessageHandler.defaultUserButtlerJamesID, receiverID: renting.userID, text: MessageHandler.DEFAULT_MESSAGE_RENTING_REQUEST_ACCEPTED)
    }
    
    func denyRenting(renting: Renting){
        if let rentingID = renting.id {
            storageAPI.deleteRentingByID(rentingID: rentingID)
            // send notification (via butler) to user that his renting has been accepted
            MessageHandler.shared.handleSend(senderID: MessageHandler.defaultUserButtlerJamesID, receiverID: renting.userID, text: MessageHandler.DEFAULT_MESSAGE_RENTING_REQUEST_DENIED)
        }
    }
}
