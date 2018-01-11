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
        StorageAPI.shared.getOfferingByID(id: rentingBeingRated.inseratID, completion: {offering in
            StorageAPI.shared.getUserByUID(UID: offering.userUID, completion: { lessorUser in
                StorageAPI.shared.getBrandByID(id: offering.brandID, completion: { offeringBrand in
                    let offeringCarModelName = offeringBrand.name + " " + offering.type
                    completion(offeringCarModelName, lessorUser)
                })
            })
        })
    }
    
    static func getAdditionalInformationForLesseeRating(rentingBeingRated: Renting, completion: @escaping (_ carModelName: String, _ lesseeUser: User) -> Void){
        StorageAPI.shared.getOfferingByID(id: rentingBeingRated.inseratID, completion: {offering in
            StorageAPI.shared.getBrandByID(id: offering.brandID, completion: { offeringBrand in
                let offeringCarModelName = offeringBrand.name + " " + offering.type
                StorageAPI.shared.getUserByUID(UID: rentingBeingRated.userID, completion: { lesseeUser in
                    completion(offeringCarModelName, lesseeUser)
                })
            })
        })
    }
    
    static func saveRating(rating: Int, ratedUser: User, explanation: String){
        let newRating = Rating(id: nil, userUID: ratedUser.id, explanation: explanation, rating: rating)
        StorageAPI.shared.saveRating(rating: newRating)
        // update user's rating
        let currentRating = ratedUser.rating
        let ratingSum = currentRating * Float(ratedUser.numberOfRatings)
        let newRatingSum:Float = ratingSum + Float(rating)
        let newNumberOfRatings:Int = ratedUser.numberOfRatings + 1
        let newUserRating = newRatingSum/Float(newNumberOfRatings)
        ratedUser.rating = newUserRating
        ratedUser.numberOfRatings = newNumberOfRatings
        StorageAPI.shared.updateUser(user: ratedUser)
    }
}
