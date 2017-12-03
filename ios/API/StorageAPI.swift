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
// TODO: implement some kind of caching

final class StorageAPI {
    static let shared = StorageAPI()
    private let fireBaseDBAccess: DatabaseReference!
    private let notificationCenter: NotificationCenter
    
    private init() {
        fireBaseDBAccess = Database.database().reference()
        notificationCenter = NotificationCenter.default
    }
    
    func getOfferings(completion: @escaping (_ offerings: [Offering]) -> Void){
        self.getFeatures(completion: {features in
            self.getOfferingsFeatures(completion: {offeringsFeatures in
                self.constructOfferings(features: features, offeringsFeatures: offeringsFeatures, completion: completion)
            })
        })
    }
    
    // TODO: only call when necessary and not (for some reason) when the app starts
    func constructOfferings(features: [Feature], offeringsFeatures: [Int: [Int]], completion: @escaping (_ offerings: [Offering]) -> Void){
        // TODO: only get offerings that match certain criteria
            self.fireBaseDBAccess.child("inserat").observeSingleEvent(of: .value, with: {snapshot in
                let receivedData = snapshot.valueInExportFormat() as! NSDictionary
                var resultOfferings:[Offering] = [Offering]()
                for (rawOfferingID, rawOfferingData) in receivedData {
                    let offeringData:NSDictionary = rawOfferingData as! NSDictionary
                    // TODO: Shorthand for this?
                    // TODO: Which way of error handling to prefer here?
                    /*guard
                        let offeringID:Int = rawOfferingID as? Int,
                        let offeringBrand:String = offeringData["brand"] as? String,
                        let offeringConsumption = offeringData["consumption"] as? Int,
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
                            print("error in constructOfferings")
                            return*/
                    guard
                        let offeringID:Int = Int(rawOfferingID as! String) as? Int,
                        let offeringBasePrice = offeringData["price"] as? Int,
                        let offeringBrand:String = offeringData["brand"] as? String,
                        let offeringConsumption = offeringData["consumption"] as? Int,
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
                            print("error in constructOfferings")
                            return
                    }
                    
                    let newOffering:Offering = Offering(id: offeringID, basePrice: offeringBasePrice, brand: offeringBrand, consumption: offeringConsumption, description: offeringDescription, fuel: offeringFuel, gear: offeringGear, hp: offeringHP, latitude: offeringLatitude, location: offeringLocation, longitude: offeringLongitude, pictureURL: offeringPictureURL, seats: offeringSeats, type: offeringType, featuresIDs: offeringsFeatures[offeringID])
                    // TODO: What to do if an offering has no features?
                    resultOfferings.append(newOffering)
                }
                completion(resultOfferings)
                /* let filteredOfferings =
                 self.notificationCenter.post(
                 name: Notification.Name(rawValue:"sendFilteredCars"),
                 object: nil,
                 userInfo: ["cars":filteredOfferings]
                 ) */
            }) { (error) in
                print(error.localizedDescription)
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
    
    func getFeatures(completion: @escaping (_ features: [Feature]) -> Void){
        self.fireBaseDBAccess.child("features").observeSingleEvent(of: .value, with: { (snapshot) in
            let receivedData = snapshot.valueInExportFormat() as! NSDictionary
            var resultExtras:[Feature] = [Feature]()
            for (featureIDRaw, featureNameRaw) in receivedData {
                let featureName:String = featureNameRaw as! String
                let featureID:String = featureIDRaw as! String // TODO: solve the conversion problem here
                
                let newFeature:Feature = Feature(name: featureName, id: Int(featureID)!)
                resultExtras.append(newFeature)
            }
            completion(resultExtras)
            /* self.notificationCenter.post(
                name: Notification.Name(rawValue:"sendExtras"),
                object: nil,
                userInfo: ["extras":resultExtras]
            )*/
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getOfferingsFeatures(completion: @escaping (_ offeringsFeatures: [Int: [Int]]) -> Void){
        self.fireBaseDBAccess.child("inserat_features").observeSingleEvent(of: .value, with: { (snapshot) in
            let receivedData = snapshot.valueInExportFormat() as! NSDictionary
            var resultOfferingsFeatures:[Int: [Int]] = [Int: [Int]]() // Map with offering ID as key and array of feature IDs a value
            for (_, associationRaw) in receivedData {
                let association:NSDictionary = associationRaw as! NSDictionary
                // TODO: Shorthand for this?
                guard
                    let featureID:Int = association["feature"] as? Int,
                    let offeringID:Int = association["inserat"] as? Int else {
                        print("error")
                        return
                }
                if (resultOfferingsFeatures[offeringID] != nil){
                    // not the first feature -> add to feature list for this offering
                    let prevOfferingFeatures = resultOfferingsFeatures[offeringID]!
                    let newOfferingFeatures = prevOfferingFeatures + [featureID]
                    resultOfferingsFeatures[offeringID] = newOfferingFeatures
                } else {
                    // first feature for this offering -> initialise array
                    resultOfferingsFeatures[offeringID] = [featureID]
                }
            }
            completion(resultOfferingsFeatures)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getRentings(completion: @escaping (_ rentings: [Renting]) -> Void){
        self.fireBaseDBAccess.child("renting").observeSingleEvent(of: .value, with: { (snapshot) in
            let receivedData = snapshot.valueInExportFormat() as! NSDictionary
            var resultRentings:[Renting] = [Renting]()
            for (rawRentingID, rawRentingData) in receivedData {
                let rentingData:NSDictionary = rawRentingData as! NSDictionary
                /* guard
                    let rentingID:Int = rawRentingID as? Int,
                    let rentingStartDateString:String = rentingData["startDate"] as? String,
                    let rentingEndDateString:String = rentingData["endDate"] as? String,
                    let rentingUserID:String = rentingData["userId"] as? String,
                    let rentingOfferingID:Int = rentingData["inseratId"] as? Int else {
                        print("error in getRentings")
                        return
                } */
                let rentingID:Int = Int(String(describing: rawRentingID))!
                let rentingStartDateString:String = rentingData["startDate"] as! String
                let rentingEndDateString:String = rentingData["endDate"] as! String
                let rentingUserID:String = rentingData["userId"] as! String
                let rentingOfferingID:Int = rentingData["inseratId"] as! Int
                let newRenting = Renting(id: rentingID, inseratID: rentingOfferingID, userID: rentingUserID, startDate: self.stringToDate(dateString: rentingStartDateString), endDate: self.stringToDate(dateString: rentingEndDateString))
                resultRentings.append(newRenting)
            }
            completion(resultRentings)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func stringToDate(dateString: String) -> Date {
        var formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        // adding one hour as the date formatter always parses the day before at 11 PM for some reason
        let newDate:Date = formatter.date(from: dateString)! + 3600 // TODO: find different fix for this
        return newDate
    }
}

