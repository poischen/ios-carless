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
        // TODO: use getOfferingWithBrandByOfferingID here
        // first get the offering (the car the user rented) and it's brand from the DB in order to assemble the car model name
        StorageAPI.shared.getOfferingWithBrandByOfferingID(offeringID: rentingBeingRated.inseratID, completion: {(offering, offeringsBrand) in
            // then get the lessor user from the DB in order to return it
            StorageAPI.shared.getUserByUID(UID: offering.userUID, completion: { lessorUser in
                let offeringCarModelName = offeringsBrand.name + " " + offering.type // assemble car model from brand name and model name
                completion(offeringCarModelName, lessorUser)
            })
        })
        /* StorageAPI.shared.getOfferingByID(id: rentingBeingRated.inseratID, completion: {offering in
            // then get the lessor user from the DB in order to return it
            StorageAPI.shared.getUserByUID(UID: offering.userUID, completion: { lessorUser in
                // then get the brand of the rented car using the brand ID from the previously received offering
                StorageAPI.shared.getBrandByID(id: offering.brandID, completion: { offeringBrand in
                    let offeringCarModelName = offeringBrand.name + " " + offering.type // assemble car model from brand name and model name
                    completion(offeringCarModelName, lessorUser)
                })
            })
        }) */
    }
    
    /*
    static func getAdditionalInformationForLesseeRating(rentingBeingRated: Renting, completion: @escaping (_ carModelName: String, _ lesseeUser: User) -> Void){
        /* // first the offering from the DB (the car the user rented) in order to assemble the car model name
        StorageAPI.shared.getOfferingByID(id: rentingBeingRated.inseratID, completion: {offering in
            // then get the lessee user from the DB in order to return it
            StorageAPI.shared.getUserByUID(UID: rentingBeingRated.userID, completion: { lesseeUser in
                // then get the brand of the rented car using the brand ID from the previously received offering
                StorageAPI.shared.getBrandByID(id: offering.brandID, completion: { offeringBrand in
                    let offeringCarModelName = offeringBrand.name + " " + offering.type // assemble car model from brand name and model name
                    completion(offeringCarModelName, lesseeUser)
                })
            })
        }) */
        // first get the offering (the car the user rented) and it's brand from the DB in order to assemble the car model name
        StorageAPI.shared.getOfferingWithBrandByOfferingID(offeringID: rentingBeingRated.inseratID, completion: {(offering, offeringsBrand) in
            // then get the lessee user from the DB in order to return it
            StorageAPI.shared.getUserByUID(UID: rentingBeingRated.userID, completion: { lesseeUser in
                let offeringCarModelName = offeringsBrand.name + " " + offering.type // assemble car model from brand name and model name
                completion(offeringCarModelName, lesseeUser)
            })
        })
    }*/
    
    static func getCarModelName(rentingBeingRated: Renting, completion: @escaping (_ carModelName: String) -> Void){
        // first get the offering (the car the user rented) and it's brand from the DB in order to assemble the car model name
        StorageAPI.shared.getOfferingWithBrandByOfferingID(offeringID: rentingBeingRated.inseratID, completion: {(offering, offeringsBrand) in
            let offeringCarModelName = offeringsBrand.name + " " + offering.type // assemble car model from brand name and model name
            completion(offeringCarModelName)
        })
    }
    
    // save a new rating (score, explanation) and update the users average rating and total ratings
    static func saveRating(rating: Int, ratedUser: User, explanation: String){
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
    }
}
