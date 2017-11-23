//
//  StorageAPI.swift
//  ios
//
//  Created by Konrad Fischer on 07.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

// singleton class for access to Firebase and maybe to local storage in the future

final class StorageAPI {
    static let shared = StorageAPI()
    private let fireBaseDBAccess: DatabaseReference!
    private let notificationCenter: NotificationCenter
    
    private var offeringsCache: [Offering]
    
    private init() {
        fireBaseDBAccess = Database.database().reference()
        notificationCenter = NotificationCenter.default
        offeringsCache = []
    }
    
    // TODO: only call when necessary and not (for some reason) when the app starts
    func getOfferings(){
        // TODO: only get offerings that match certain criteria
        if (self.offeringsCache.count > 0){
            self.notificationCenter.post(
                name: Notification.Name(rawValue:"sendOfferings"),
                object: nil,
                userInfo: ["offerings":self.offeringsCache]
            )
        } else {
            var resultOfferings:[Offering] = []
            self.fireBaseDBAccess.child("inserat").observeSingleEvent(of: .value, with: {snapshot in
                let receivedData = snapshot.valueInExportFormat() as! NSDictionary
                var resultOfferings:[Offering] = [Offering]()
                for (_, rawOfferingData) in receivedData {
                    let offeringData:NSDictionary = rawOfferingData as! NSDictionary
                    // TODO: Shorthand for this?
                    guard
                        let offeringBrand:String = offeringData["brand"] as? String,
                        let offeringConsumption = offeringData["consumption"] as? Float,
                        let offeringDescription = offeringData["description"] as? String,
                        let offeringFuel = offeringData["fuel"] as? String,
                        let offeringGear = offeringData["gear"] as? String,
                        let offeringHP = offeringData["hp"] as? Int,
                        let offeringLatitude = offeringData["latitude"] as? Float,
                        let offeringLocation = offeringData["location"] as? String,
                        let offeringLongitude = offeringData["longitude"] as? Float,
                        let offeringPictureURL = offeringData["picture"] as? String,
                        let offeringSeats = offeringData["seats"] as? Int,
                        let offeringType = offeringData["type"] as? String else {
                            print("error")
                            return
                    }
                    
                    let newOffering:Offering = Offering(brand: offeringBrand, consumption: offeringConsumption, description: offeringDescription, fuel: offeringFuel, gear: offeringGear, hp: offeringHP, latitude: offeringLatitude, location: offeringLocation, longitude: offeringLongitude, pictureURL: offeringPictureURL, seats: offeringSeats, type: offeringType)
                    resultOfferings.append(newOffering)
                    resultOfferings.append(newOffering)
                }
                self.notificationCenter.post(
                    name: Notification.Name(rawValue:"sendOfferings"),
                    object: nil,
                    userInfo: ["offerings":resultOfferings]
                )
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func filterOfferings(filter: Filter) {
        // TODO: implement
        /* let filteredOfferings =
        self.notificationCenter.post(
            name: Notification.Name(rawValue:"sendFilteredCars"),
            object: nil,
            userInfo: ["cars":filteredOfferings]
        ) */
    }
    
    func getExtras(){
        fireBaseDBAccess.child("features").observeSingleEvent(of: .value, with: { (snapshot) in
            let receivedData = snapshot.valueInExportFormat() as! NSDictionary
            var resultExtras:[Feature] = [Feature]()
            for (featureIDRaw, featureNameRaw) in receivedData {
                let featureName:String = featureNameRaw as! String
                let featureID:String = featureIDRaw as! String // TODO: solve the conversion problem here
                
                let newFeature:Feature = Feature(name: featureName, id: Int(featureID)!)
                resultExtras.append(newFeature)
            }
            self.notificationCenter.post(
                name: Notification.Name(rawValue:"sendExtras"),
                object: nil,
                userInfo: ["extras":resultExtras]
            )
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
