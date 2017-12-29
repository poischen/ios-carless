//
//  RateModel.swift
//  ios
//
//  Created by Konrad Fischer on 29.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class RateModel {
    static func getRatingInformationFromDB(rentingBeingRated: Renting, completion: @escaping (_ carModelName: String, _ lessorUser: User) -> Void){
        StorageAPI.shared.getOfferingByID(id: rentingBeingRated.inseratID, completion: {offering in
            StorageAPI.shared.getUserByUID(UID: offering.userUID, completion: { lessorUser in
                StorageAPI.shared.getBrandByID(id: offering.brandID, completion: { offeringBrand in
                    let offeringCarModelName = offeringBrand.name + " " + offering.type
                    completion(offeringCarModelName, lessorUser)
                })
            })
        })
    }
}
