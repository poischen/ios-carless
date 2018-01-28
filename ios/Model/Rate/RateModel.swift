//
//  RateModel.swift
//  ios
//
//  Created by Konrad Fischer on 29.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class RateModel {
    static func getAdditionalInformationForLessorRating(rentingBeingRated: Renting, completion: @escaping (_ carModelName: String, _ lessorUser: User) -> Void){
        // first get the offering (the car the user rented) and it's brand from the DB in order to assemble the car model name
        // (using the getCarModelNameForLesseeRating function here is not possible as we can't get the lessor's user ID directly from the renting)
        StorageAPI.shared.getOfferingWithBrandByOfferingID(offeringID: rentingBeingRated.inseratID, completion: {offeringResult in
            if let (offering, offeringsBrand) = offeringResult {
                // offering found -> assemble car name
                let carName = offeringsBrand.name + " " + offering.type // assemble car model from brand name and model name
                // get the lessor user from the DB in order to return it
                StorageAPI.shared.getUserByUID(UID: offering.userUID, completion: { lessorUser in
                    completion(carName, lessorUser)
                })
            }
        })
        
    }
    
    static func getCarModelNameForLesseeRating(rentingBeingRated: Renting, completion: @escaping (_ carModelName: String) -> Void){
        // first get the offering (the car the user rented) and it's brand from the DB in order to assemble the car model name
        StorageAPI.shared.getOfferingWithBrandByOfferingID(offeringID: rentingBeingRated.inseratID, completion: {offeringResult in
            if let (offering, offeringsBrand) = offeringResult {
                // offering found -> assemble car model from brand name and model name
                let offeringCarModelName = offeringsBrand.name + " " + offering.type
                completion(offeringCarModelName)
            }
        })
    }
    
    // save a new rating (score, explanation) and update the users average rating and total ratings
    // if ratingLessee is false we assume that the lessor is being rated
    static func saveRating(rating: Int, ratedUser: User, explanation: String, renting: Renting, ratingLessee: Bool){
        // construct rating object, ID is later filled by StorageAPI with a unique ID provided by Firebase
        let newRating = Rating(id: nil, userUID: ratedUser.id, explanation: explanation, rating: rating)
        // save rating to DB
        StorageAPI.shared.saveRating(rating: newRating)
        // update user's average rating
        let currentAverageRating = ratedUser.rating
        let prevRatingsSum = currentAverageRating * Float(ratedUser.numberOfRatings) // get sum of ratings until now
        let newRatingSum:Float = prevRatingsSum + Float(rating) // add new rating to sum
        let newNumberOfRatings:Int = ratedUser.numberOfRatings + 1 // increment number of ratings
        let newAverageRating = newRatingSum/Float(newNumberOfRatings) // calculate new average rating
        ratedUser.rating = newAverageRating
        ratedUser.numberOfRatings = newNumberOfRatings
        StorageAPI.shared.updateUser(user: ratedUser) // update user's rating in the DB
        // update renting to prevent repeated rating of one renting
        if (ratingLessee) {
            // lessee is being rated -> lessor wrote this rating
            renting.lessorHasRated = true
            StorageAPI.shared.updateRenting(renting: renting)
        } else {
            // lessor is being rated -> lessee wrote this rating
            renting.lesseeHasRated = true
            StorageAPI.shared.updateRenting(renting: renting)
        }
    }
}
