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
import FirebaseStorage
import FirebaseAuth

protocol FetchData: class {
    func dataReceived(users: [User]);
}


// singleton class for access to Firebase and maybe to local storage in the future
// TODO: implement some kind of caching

final class StorageAPI {
    static let shared = StorageAPI()
    private let fireBaseDBAccess: DatabaseReference!
    private let notificationCenter: NotificationCenter
    
    // DB references
    private let offeringsDBReference: DatabaseReference
    private let rentingsDBReference: DatabaseReference
    private let featuresDBReference: DatabaseReference
    private let offeringsFeaturesDBReference: DatabaseReference
    private let vehicleTypesDBReference: DatabaseReference
    
    //value will not be instantiated until it is needed
    weak var delegate: FetchData?;
    
    var userName = "";
    
    //returns Project URL from Firebase
    var dbRef: DatabaseReference {
        return Database.database().reference();
    }
    
    var usersRef: DatabaseReference{
        return dbRef.child(Constants.USERS);
    }
    
    var messagesRef: DatabaseReference {
        return dbRef.child(Constants.MESSAGES);
    }
    
    var mediaMessagesRef: DatabaseReference{
        return dbRef.child(Constants.MEDIA_MESSAGES);
    }
    
    //where media files are stored
    var storageRef: StorageReference {
        return Storage.storage().reference(forURL: "gs://ioscars-32e69.appspot.com");
    }
    
    var imageStorageRef: StorageReference {
        return storageRef.child(Constants.IMAGE_STORAGE);
    }
    
    var videoStorageRef: StorageReference {
        return storageRef.child(Constants.VIDEO_STORAGE);
    }
    
    private init() {
        fireBaseDBAccess = Database.database().reference()
        notificationCenter = NotificationCenter.default
        self.offeringsDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_OFFERINGS)
        self.rentingsDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_RENTINGS)
        self.featuresDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_FEATURES)
        self.offeringsFeaturesDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_OFFERINGS_FEATURES)
        self.vehicleTypesDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_VEHICLE_TYPES)
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
            self.offeringsDBReference.observeSingleEvent(of: .value, with: {snapshot in
                let receivedData = snapshot.valueInExportFormat() as! NSDictionary
                var resultOfferings:[Offering] = [Offering]()
                for (rawOfferingID, rawOfferingData) in receivedData {
                    let offeringData:NSDictionary = rawOfferingData as! NSDictionary
                    // TODO: Shorthand for this?
                    // TODO: Which way of error handling to prefer here?
                    // TODO: necessary to get description from DB?
                    guard
                        let offeringID:String = rawOfferingID as? String,
                        let offeringBasePrice = offeringData[DBConstants.PROPERTY_NAME_OFFERING_PRICE] as? Int,
                        let offeringBrand:String = offeringData[DBConstants.PROPERTY_NAME_OFFERING_BRAND] as? String,
                        let offeringConsumption = offeringData[DBConstants.PROPERTY_NAME_OFFERING_CONSUMPTION] as? Int,
                        let offeringDescription = offeringData[DBConstants.PROPERTY_NAME_OFFERING_DESCRIPTION] as? String,
                        let offeringFuel = offeringData[DBConstants.PROPERTY_NAME_OFFERING_FUEL] as? String,
                        let offeringGear = offeringData[DBConstants.PROPERTY_NAME_OFFERING_GEAR] as? String,
                        let offeringHP = offeringData[DBConstants.PROPERTY_NAME_OFFERING_HORSEPOWER] as? Int,
                        let offeringLatitude = offeringData[DBConstants.PROPERTY_NAME_OFFERING_LATITUDE] as? Float,
                        let offeringLocation = offeringData[DBConstants.PROPERTY_NAME_OFFERING_CITY] as? String,
                        let offeringLongitude = offeringData[DBConstants.PROPERTY_NAME_OFFERING_LONGITUDE] as? Float,
                        let offeringPictureURL = offeringData[DBConstants.PROPERTY_NAME_OFFERING_PICTURE_URL] as? String,
                        let offeringSeats = offeringData[DBConstants.PROPERTY_NAME_OFFERING_SEATS] as? Int,
                        let offeringType = offeringData[DBConstants.PROPERTY_NAME_OFFERING_TYPE] as? String,
                        let offeringVehicleTypeID = offeringData[DBConstants.PROPERTY_NAME_OFFERING_VEHICLE_TYPE_ID] as? Int else {
                            print("error in constructOfferings")
                            return
                    }
                    
                    let newOffering:Offering = Offering(id: Int(offeringID)!, basePrice: offeringBasePrice, brand: offeringBrand, consumption: offeringConsumption, description: offeringDescription, fuel: offeringFuel, gear: offeringGear, hp: offeringHP, latitude: offeringLatitude, location: offeringLocation, longitude: offeringLongitude, pictureURL: offeringPictureURL, seats: offeringSeats, type: offeringType, featuresIDs: offeringsFeatures[Int(offeringID)!], vehicleTypeID: offeringVehicleTypeID)
                    // TODO: What to do if an offering has no features?
                    resultOfferings.append(newOffering)
                }
                completion(resultOfferings)
            }) { (error) in
                print(error.localizedDescription)
            }
    }
    
    func getFeatures(completion: @escaping (_ features: [Feature]) -> Void){
        self.featuresDBReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let receivedData = snapshot.valueInExportFormat() as! NSDictionary
            var resultExtras:[Feature] = [Feature]()
            for (featureIDRaw, featureNameRaw) in receivedData {
                guard
                    let featureName:String = featureNameRaw as? String,
                    let featureID:String = featureIDRaw as? String else { // TODO: solve the conversion problem here
                        print("error in getFeatures")
                        return
                }
                
                let newFeature:Feature = Feature(name: featureName, id: Int(featureID)!)
                resultExtras.append(newFeature)
            }
            completion(resultExtras)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getOfferingsFeatures(completion: @escaping (_ offeringsFeatures: [Int: [Int]]) -> Void){
        self.offeringsFeaturesDBReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let receivedData = snapshot.valueInExportFormat() as! NSDictionary
            var resultOfferingsFeatures:[Int: [Int]] = [Int: [Int]]() // Map with offering ID as key and array of feature IDs a value
            for (_, associationRaw) in receivedData {
                let association:NSDictionary = associationRaw as! NSDictionary
                // TODO: Shorthand for this?
                guard
                    let featureID:Int = association[DBConstants.PROPERTY_NAME_OFFERINGS_FEATURES_FEATURE] as? Int,
                    let offeringID:Int = association[DBConstants.PROPERTY_NAME_OFFERINGS_FEATURES_OFFERING] as? Int else {
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
        self.rentingsDBReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let receivedData = snapshot.valueInExportFormat() as! NSDictionary
            var resultRentings:[Renting] = [Renting]()
            for (rawRentingID, rawRentingData) in receivedData {
                let rentingData:NSDictionary = rawRentingData as! NSDictionary
                guard
                    let rentingID:String = rawRentingID as? String,
                    let rentingStartDateString:String = rentingData[DBConstants.PROPERTY_NAME_RENTING_START_DATE] as? String,
                    let rentingEndDateString:String = rentingData[DBConstants.PROPERTY_NAME_RENTING_END_DATE] as? String,
                    let rentingUserID:String = rentingData[DBConstants.PROPERTY_NAME_RENTING_USER_ID] as? String,
                    let rentingOfferingID:Int = rentingData[DBConstants.PROPERTY_NAME_RENTING_OFFERING_ID] as? Int else {
                        print("error in getRentings")
                        return
                }
                let newRenting = Renting(id: Int(rentingID)!, inseratID: rentingOfferingID, userID: rentingUserID, startDate: self.stringToDate(dateString: rentingStartDateString), endDate: self.stringToDate(dateString: rentingEndDateString))
                resultRentings.append(newRenting)
            }
            completion(resultRentings)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getVehicleTypes(completion: @escaping (_ vehicleTypes: [VehicleType]) -> Void){
        self.vehicleTypesDBReference.observeSingleEvent(of: .value, with: { (snapshot) in
            let receivedData = snapshot.valueInExportFormat() as! NSDictionary
            var resultVehicleTypes:[VehicleType] = [VehicleType]()
            for (vehicleTypeIDRaw, vehicleTypeDataRaw) in receivedData {
                let vehicleTypeData:NSDictionary = vehicleTypeDataRaw as! NSDictionary
                guard
                    let vehicleTypeName:String = vehicleTypeData[DBConstants.PROPERTY_NAME_VEHICLE_TYPE_NAME] as? String,
                    let vehicleTypeIconURL:String = vehicleTypeData[DBConstants.PROPERTY_NAME_VEHICLE_TYPE_ICON_URL] as? String,
                    let vehicleTypeID:String = vehicleTypeIDRaw as? String else {
                        print("error in getFeatures")
                        return
                }
                
                let newVehicleType:VehicleType = VehicleType(id: Int(vehicleTypeID)!, name: vehicleTypeName, iconURL: vehicleTypeIconURL)
                resultVehicleTypes.append(newVehicleType)
            }
            completion(resultVehicleTypes)
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
    
    //stores User in Database
    //User is not being saved for now (Video 6 of the Tutorial)
    func saveUser(withID: String, email: String, password: String){
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password];
        
        usersRef.child(withID).setValue(data);
    }
    
    func getUsers() {
        
        //watching, observing database
        //see all the values in Users Reference
        usersRef.observeSingleEvent(of: DataEventType.value){
            (snapshot: DataSnapshot) in
            
            //empty array of users
            var users = [User]();
            
            //testing if value is type of NSDictionary
            if let theUsers = snapshot.value as? NSDictionary {
                
                //filter for every key, value pair inside of the dictionary
                for (key, value) in theUsers {
                    
                    if let userData = value as? NSDictionary{
                        
                        // fetch the data as String
                        if let email = userData[Constants.EMAIL] as? String {
                            
                            let id = key as! String;
                            let newUser = User(id: id, name: email);
                            
                            //append it in the empty array
                            users.append(newUser);
                        }
                    }
                }
            }
            self.delegate?.dataReceived(users: users);
        }
    }
    
    
    //gets UserID in Firebase
    func userID() -> String {
        return Auth.auth().currentUser!.uid;
    }
    
    
}

