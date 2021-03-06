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
import UIKit


// singleton class for access to Firebase and maybe to local storage in the future

final class StorageAPI {
    static let shared = StorageAPI()
    private let fireBaseDBAccess: DatabaseReference!
    
    // DB references
    private let offeringsDBReference: DatabaseReference
    private let availibilityDBReference: DatabaseReference
    private let rentingsDBReference: DatabaseReference
    private let featuresDBReference: DatabaseReference
    private let offeringsFeaturesDBReference: DatabaseReference
    private let vehicleTypesDBReference: DatabaseReference
    private let gearsDBReference: DatabaseReference
    private let brandsDBReference: DatabaseReference
    private let fuelDBReference: DatabaseReference
    private let ratingsDBReference: DatabaseReference
    private let lessorRatings: DatabaseReference
    
    var usersRef: DatabaseReference
    var messagesRef: DatabaseReference
    var userMessagesRef: DatabaseReference
    var mediaMessagesRef: DatabaseReference
    var storageRef: StorageReference
    var imageStorageRef: StorageReference
    var videoStorageRef: StorageReference
    
    let STORAGE_URL = "gs://ioscars-32e69.appspot.com"
    
    static let STORAGE_API_SUCCESS = "Successfully saved"
    
    var offerImageStorageRef: StorageReference {
        return storageRef.child(DBConstants.IMAGE_STORAGE_OFFER)
    }
    
    var profileImageStorageRef: StorageReference {
        return storageRef.child(DBConstants.IMAGE_STORAGE_PROFILE)
    }
    
    private init() {
        // enable caching but also enable keepSynced in order to e.g. get the newest offerings
        Database.database().isPersistenceEnabled = true
        fireBaseDBAccess = Database.database().reference()
        fireBaseDBAccess.keepSynced(true)
        
        // create "table" references
        self.offeringsDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_OFFERINGS)
        self.availibilityDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_OFFERINGS_AVAILIBILITY)
        self.rentingsDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_RENTINGS)
        self.featuresDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_FEATURES)
        self.offeringsFeaturesDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_OFFERINGS_FEATURES)
        self.vehicleTypesDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_VEHICLE_TYPES)
        self.gearsDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_GEARS)
        self.brandsDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_BRANDS)
        self.fuelDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_FUELS)
        self.ratingsDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_RATINGS)
        self.lessorRatings = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_RATINGS)
        
        self.usersRef = fireBaseDBAccess.child(DBConstants.USERS)
        self.messagesRef = fireBaseDBAccess.child(DBConstants.MESSAGES)
        self.userMessagesRef = fireBaseDBAccess.child(DBConstants.USER_MESSAGES)
        self.mediaMessagesRef = fireBaseDBAccess.child(DBConstants.MEDIA_MESSAGES)
        self.storageRef = Storage.storage().reference(forURL: STORAGE_URL)
        self.imageStorageRef = storageRef.child(DBConstants.IMAGE_STORAGE)
        self.videoStorageRef = storageRef.child(DBConstants.VIDEO_STORAGE)
    }
    
    // get all offerings
    func getOfferings(completion: @escaping (_ offerings: [Offering]) -> Void){
        self.offeringsDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultOfferings:[Offering] = []
            for childRaw in snapshot.children {
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw), let offering = Offering.init(id: stringID, dict: dict) {
                    resultOfferings.append(offering)
                } else {
                    print("getOfferings: error while converting offering")
                }
            }
            completion(resultOfferings)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get a specific offering by ID
    func getOfferingByID(id: String, completion: @escaping (_ offering: Offering?) -> Void){
        self.offeringsDBReference.queryOrderedByKey().queryEqual(toValue: id).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                let childRaw = snapshot.children.nextObject()
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw!), let offering = Offering.init(id: stringID, dict: dict) {
                    completion(offering)
                } else {
                    print("error in get getOfferingByID")
                }
            } else if (snapshot.childrenCount == 0){
                // no offering with that ID found
                completion(nil)
            } else if (snapshot.childrenCount > 1) {
                print("getOfferingByID: more than one offering found")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get all features
    func getFeatures(completion: @escaping (_ features: [Feature]) -> Void){
        self.featuresDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultFeatures:[Feature] = []
            for childRaw in snapshot.children {
                if let (intID, dict) = self.snapshotToIntIDAndDict(childRaw: childRaw), let feature = Feature.init(id: intID, dict: dict){
                    resultFeatures.append(feature)
                } else {
                    print("getFeatures: error while converting feature")
                }
            }
            completion(resultFeatures)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get a dictionary with the ID of an offering as key and a list of the ID's of it's features as value
    // this method does not follow the dictionary convertible scheme as the offerings' features are best reprensented by a map and not by an object
    func getOfferingsFeatures(completion: @escaping (_ offeringsFeatures: [String: [Int]]) -> Void){
        self.offeringsFeaturesDBReference.observeSingleEvent(of: .value, with: { (snapshot) in
            if let receivedData = snapshot.valueInExportFormat() as? NSDictionary{
                var resultOfferingsFeatures:[String: [Int]] = [String: [Int]]() // dictionary with offering ID as key and array of feature IDs a value
                for (_, associationRaw) in receivedData {
                    guard
                        let association:NSDictionary = associationRaw as? NSDictionary,
                        let featureID:Int = association[DBConstants.PROPERTY_NAME_OFFERINGS_FEATURES_FEATURE] as? Int,
                        let offeringID:String = association[DBConstants.PROPERTY_NAME_OFFERINGS_FEATURES_OFFERING] as? String else {
                            print("error in getOfferingsFeatures")
                            return
                    }
                    if var currentOfferingsFeatures = resultOfferingsFeatures[offeringID] {
                        // not the first feature -> add to feature list for this offering
                        currentOfferingsFeatures.append(featureID)
                        resultOfferingsFeatures[offeringID] = currentOfferingsFeatures
                    } else {
                        // first feature for this offering -> initialise features array
                        resultOfferingsFeatures[offeringID] = [featureID]
                    }
                }
                completion(resultOfferingsFeatures)

            } else {
                print("could not convert snapshot in getOfferingsFeatures")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    

    func getFeatureByID(id: Int, completion: @escaping (_ feature: Feature) -> Void){
            self.featuresDBReference.queryOrderedByKey().queryEqual(toValue: String(id)).observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.childrenCount == 1 {
                    let childRaw = snapshot.children.nextObject()
                    if let child = childRaw as? DataSnapshot, let dict = child.value as? [String:AnyObject] {
                        let featureID = Int(child.key)!
                        if let feature = Feature.init(id: featureID, dict: dict) {
                            completion(feature)
                        } else {
                            print("error in get getFeatureByID")
                        }
                    } else {
                        print("error in get getFeatureByID")
                    }
                } else {
                    print("no featureor more than one feature found")
                }
            }) { (error) in
                print(error.localizedDescription)
            }
    }
    
    // get all rentings
    func getRentings(completion: @escaping (_ rentings: [Renting]) -> Void){
        self.rentingsDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultRentings:[Renting] = []
            for childRaw in snapshot.children {
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw), let renting = Renting.init(id: stringID, dict: dict) {
                    resultRentings.append(renting)
                } else {
                    print("getRentings: error while converting renting")
                }
            }
            completion(resultRentings)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get all vehicle types
    func getVehicleTypes(completion: @escaping (_ vehicleTypes: [VehicleType]) -> Void){
        self.vehicleTypesDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultTypes:[VehicleType] = []
            for childRaw in snapshot.children {
                if let (intID, dict) = self.snapshotToIntIDAndDict(childRaw: childRaw), let type = VehicleType.init(id: intID, dict: dict) {
                    resultTypes.append(type)
                } else {
                    print("getVehicleTypes: error while converting feature")
                }
            }
            completion(resultTypes)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get a specific vehicle type by ID
    func getVehicleTypeByID(id: Int, completion: @escaping (_ fuel: VehicleType) -> Void){
        self.vehicleTypesDBReference.queryOrderedByKey().queryEqual(toValue: String(id)).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                let childRaw = snapshot.children.nextObject()
                if let child = childRaw as? DataSnapshot, let dict = child.value as? [String:AnyObject] {
                    let vehicleTypeID = Int(child.key)!
                    if let vehicleType = VehicleType.init(id: vehicleTypeID, dict: dict) {
                        completion(vehicleType)
                    } else {
                        print("error in get getVehicleTypeByID")
                    }
                } else {
                    print("error in get getVehicleTypeByID")
                }
            } else {
                print("no vehicle type or more than one vehicle type found")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get all brands
    func getBrands(completion: @escaping (_ brands: [Brand]) -> Void){
        self.brandsDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultBrands:[Brand] = []
            for childRaw in snapshot.children {
                if let (intID, dict) = self.snapshotToIntIDAndDict(childRaw: childRaw), let brand = Brand.init(id: intID, dict: dict) {
                    resultBrands.append(brand)
                } else {
                    print("getBrands: error while converting brand")
                }
            }
            completion(resultBrands)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get a specific brand by ID
    func getBrandByID(id: Int, completion: @escaping (_ brand: Brand) -> Void){
        self.brandsDBReference.queryOrderedByKey().queryEqual(toValue: String(id)).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                let childRaw = snapshot.children.nextObject()
                if let (intID, dict) = self.snapshotToIntIDAndDict(childRaw: childRaw!), let brand = Brand.init(id: intID, dict: dict) {
                    completion(brand)
                } else {
                    print("error in get getBrandByID")
                }
            } else {
                print("no brand or more than one brand found")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get all fuels
    func getFuels(completion: @escaping (_ fuels: [Fuel]) -> Void){
        self.fuelDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultFuels:[Fuel] = []
            for childRaw in snapshot.children {
                if let (intID, dict) = self.snapshotToIntIDAndDict(childRaw: childRaw), let fuel = Fuel.init(id: intID, dict: dict) {
                    resultFuels.append(fuel)
                } else {
                    print("getBrands: error while converting brand")
                }
            }
            completion(resultFuels)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get a specific fuel by ID
    func getFuelByID(id: Int, completion: @escaping (_ fuel: Fuel) -> Void){
        self.fuelDBReference.queryOrderedByKey().queryEqual(toValue: String(id)).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                let childRaw = snapshot.children.nextObject()
                if let (intID,dict) = self.snapshotToIntIDAndDict(childRaw: childRaw!), let fuel = Fuel.init(id: intID, dict: dict) {
                    completion(fuel)
                } else {
                    print("error in get getFuelByID")
                }
            } else {
                print("no fuel or more than one fuel found")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get all gears
    func getGears(completion: @escaping (_ gears: [Gear]) -> Void){
        self.gearsDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultGears:[Gear] = []
            for childRaw in snapshot.children {
                if let (intID, dict) = self.snapshotToIntIDAndDict(childRaw: childRaw), let gear = Gear.init(id: intID, dict: dict) {
                    resultGears.append(gear)
                } else {
                    print("getGears: error while converting gear")
                }
            }
            completion(resultGears)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get a specific gear by ID
    func getGearByID(id: Int, completion: @escaping (_ gear: Gear) -> Void){
        self.gearsDBReference.queryOrderedByKey().queryEqual(toValue: String(id)).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                let childRaw = snapshot.children.nextObject()
                if let (intID, dict) = self.snapshotToIntIDAndDict(childRaw: childRaw!), let gear = Gear.init(id: intID, dict: dict) {
                    completion(gear)
                } else {
                    print("error in get getGearByID")
                }
            } else {
                print("no gear or more than one gear found")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // save a rating to the DB
    func saveRating(rating: Rating){
        let ratingAsDict = rating.dict
        self.ratingsDBReference.childByAutoId().setValue(ratingAsDict) {(error,_) in
            if let currentError = error {
                print("error in saveRating:")
                print(currentError.localizedDescription)
            }
        }
    }
    
    // update a user
    func updateUser(user: User){
        let userAsDict = user.dict
        self.usersRef.child(user.id).setValue(userAsDict)
    }
    
    func updateUserProfilePicture(userID: String, imgUrl: String){
        self.usersRef.child(userID).child(DBConstants.PROFILEIMG).setValue(imgUrl)
    }
    
    //store offer in db
    func saveOffering(offer: Offering, completion: @escaping (_ offering: Offering) -> Void){
        let offerAsDict = offer.dict
        let key = offeringsDBReference.childByAutoId().key
        
        offer.id = key
        
        self.offeringsDBReference.child(key).setValue(offerAsDict) { (error, ref) in
            if (error != nil) {
                print(error!.localizedDescription)
            } else {
                completion(offer)
            }
        }
    }
    
    // generate a unique ID for a renting
    func generateRentingKey(completion: @escaping (_ rentingID: String) -> Void){
        let rentingKey = rentingsDBReference.childByAutoId().key
        completion(rentingKey)
    }
    
    // save a renting to the DB
    func saveRenting(renting: Renting, completion: @escaping (_ status: String) -> Void){
        let rentingAsDict = renting.dict
        self.rentingsDBReference.child(renting.id!).setValue(rentingAsDict) { (error, ref) in
            if (error != nil) {
                print(error!.localizedDescription)
                completion(error!.localizedDescription)
            } else {
                completion(StorageAPI.STORAGE_API_SUCCESS)
            }
        }
    }
    
    
    //store availibility of offer in db
    func saveAvailibility(blockedDates: [Date]?, offerID: String){
        let availibilityKey = availibilityDBReference.childByAutoId().key
        offeringsDBReference.child(offerID).child(DBConstants.PROPERTY_NAME_OFFERINGS_BLOCKED).setValue(availibilityKey)
        
        let reference = availibilityDBReference.child(availibilityKey)
        if let blockedDates = blockedDates {
            for blockedDay in blockedDates {
                let blockedDayKey = reference.childByAutoId().key
                let entryReference = reference.child(blockedDayKey)
                
                let blockedDayConverted = Renting.dateToIntTimestamp(date: blockedDay)
                print(blockedDayConverted)
                
                entryReference.setValue(blockedDayConverted);
            }
        }

    }
    
    //store features of an offer in db
    func saveFeatures(features: [Int], offerID: String){
        for feature in features {
            let featureKey = offeringsFeaturesDBReference.childByAutoId().key
            offeringsFeaturesDBReference.child(featureKey).child(DBConstants.PROPERTY_NAME_OFFERINGS_FEATURES_FEATURE).setValue(feature)
            offeringsFeaturesDBReference.child(featureKey).child(DBConstants.PROPERTY_NAME_OFFERINGS_FEATURES_OFFERING).setValue(offerID)
        }
    }
    
    
    //stores a new user in Database
    func saveUser(withID: String, name: String, email: String, rating: Float, profileImg: String, deviceID: String){
        let newUser = User(id: withID, name: name, email: email, rating: rating, profileImgUrl: profileImg, numberOfRatings: 0, deviceID: deviceID)
        
        usersRef.child(withID).setValue(newUser.dict)
    }
    
    // get all users
    func getUsers(completion: @escaping (_ users: [User]) -> Void){
        self.usersRef.observeSingleEvent(of: .value, with: { snapshot in
            var resultUsers:[User] = []
            for childRaw in snapshot.children {
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw), let user = User.init(id: stringID, dict: dict) {
                    resultUsers.append(user)
                } else {
                    print("getUsers: error while converting user")
                }
            }
            completion(resultUsers)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // get a specific user by his ID
    func getUserByUID(UID: String, completion: @escaping (_ user: User) -> Void){
        self.usersRef.queryOrderedByKey().queryEqual(toValue: UID).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                let childRaw = snapshot.children.nextObject()
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw!), let user = User(id: stringID, dict: dict) {
                    completion(user)
                } else {
                    print("error in get getUserByUID")
                }
            } else {
                print("no user or more than one user found")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // gets the cars the rentings for a specific user
    func getRentingsByUserUID(userUID: String, completion: @escaping (_ rentings: [Renting]) -> Void){
        self.rentingsDBReference.queryOrdered(byChild: Renting.RENTING_USER_ID_KEY).queryEqual(toValue: userUID).observeSingleEvent(of: .value, with: {snapshot in
            var resultRentings:[Renting] = []
            for childRaw in snapshot.children {
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw), let renting = Renting.init(id: stringID, dict: dict) {
                    resultRentings.append(renting)
                } else {
                    print("getRentingsByUserUID: error while converting renting")
                }
            }
            completion(resultRentings)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // subscript to the rentings of a specific user (callback is called on change)
    func subscribeToUsersRentings(userUID: String, completion: @escaping (_ rentings: [Renting]) -> Void){
        self.rentingsDBReference.queryOrdered(byChild: Renting.RENTING_USER_ID_KEY).queryEqual(toValue: userUID).observe(.value, with: {snapshot in
            var resultRentings:[Renting] = []
            for childRaw in snapshot.children {
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw), let renting = Renting.init(id: stringID, dict: dict) {
                    resultRentings.append(renting)
                } else {
                    print("subscribeToUsersRenting: error while converting renting")
                }
            }
            completion(resultRentings)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // subscript to the rentings of a specific offering (callback is called on change)
    func subscribeToRentingsForOffering(offeringID: String, completion: @escaping (_ rentings: [Renting]) -> Void){
        self.rentingsDBReference.queryOrdered(byChild: Renting.RENTING_OFFERING_ID_KEY).queryEqual(toValue: offeringID).observe(.value, with: {snapshot in
            var resultRentings:[Renting] = []
            for childRaw in snapshot.children {
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw), let renting = Renting.init(id: stringID, dict: dict) {
                    resultRentings.append(renting)
                } else {
                    print("subscribeToRentingsForOffering: error while converting renting")
                }
            }
            completion(resultRentings)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // subscript all rentings of a specific offering
    func getRentingsByOfferingID(offeringID: String, completion: @escaping (_ rentings: [Renting]) -> Void){
        self.rentingsDBReference.queryOrdered(byChild: Renting.RENTING_OFFERING_ID_KEY).queryEqual(toValue: offeringID).observeSingleEvent(of: .value, with: {snapshot in
            var resultRentings:[Renting] = []
            for childRaw in snapshot.children {
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw), let renting = Renting.init(id: stringID, dict: dict) {
                    resultRentings.append(renting)
                } else {
                    print("getRentingsByOfferingID: error while converting renting")
                }
            }
            completion(resultRentings)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // update a renting in the DB
    func updateRenting(renting: Renting){
        let rentingAsDict = renting.dict
        if let rentingID = renting.id {
            self.rentingsDBReference.child(rentingID).setValue(rentingAsDict)
        }
    }
    
    func deleteRentingByID(rentingID: String){
        self.rentingsDBReference.child(rentingID).removeValue()
    }

    func deleteOfferingByID(offeringID: String){
        self.offeringsDBReference.child(offeringID).removeValue()
    }
    
    // get the offerings of a specific user
    func getOfferingsByUserUID(userUID: String, completion: @escaping (_ offerings: [Offering]) -> Void){
        self.offeringsDBReference.queryOrdered(byChild: Offering.OFFERING_USER_UID_KEY).queryEqual(toValue: userUID).observeSingleEvent(of: .value, with: {snapshot in
            var resultOfferings:[Offering] = []
            for childRaw in snapshot.children {
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw), let offering = Offering.init(id: stringID, dict: dict) {
                    resultOfferings.append(offering)
                } else {
                    print("getOfferingsByUserUID: error while converting offering")
                }
            }
            completion(resultOfferings)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //get the id of an offering's blocked days by the id of the givwn offering
    func getBlockedDaysIDByOfferingID(offeringID: String, completion: @escaping (_ blockedDayIDs: String) -> Void){
        self.offeringsDBReference.child(offeringID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get blocked Days ID value
            let id = snapshot.value as? NSDictionary
            let blockedDaysID = id?[DBConstants.PROPERTY_NAME_OFFERINGS_BLOCKED] as? String ?? ""
            completion(blockedDaysID)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getBlockedDaysByID(bdID: String, completion: @escaping (_ blockedDays: [Int]) -> Void){
        self.availibilityDBReference.child(bdID).observeSingleEvent(of: .value, with: { snapshot in
            var blockedDays: [Int] = []
            for childRaw in snapshot.children {
                if let child = childRaw as? DataSnapshot{
                    let blockedDay = child.value as! Int
                    blockedDays.append(blockedDay)
                }
            }
            completion(blockedDays)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    //gets UserID in Firebase
    func userID() -> String? {
        if let currentUser = Auth.auth().currentUser {
            return currentUser.uid
        } else {
            return nil
        }
    }
    
    func getUserProfileImageUrl(uID: String, completion: @escaping (_ profileImgUrl: String) -> Void){
        self.usersRef.child(uID).observeSingleEvent(of: .value, with: { (snapshot) in
            let url = snapshot.value as? NSDictionary
            let profileImgUrl = url?[DBConstants.PROFILEIMG] as? String ?? ""
            completion(profileImgUrl)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //store an image to storage, return URL or Error Message
    func uploadImage(_ image: UIImage, ref: StorageReference, progressBar: UIProgressView?, progressLabel: UILabel?, completionBlock: @escaping (_ url: URL?, _ errorMessage: String?) -> Void) {
        let imageName = "\(userID())_\(Date().timeIntervalSince1970).jpg"
        let imageReference = ref.child(imageName)

        if let imageData = UIImageJPEGRepresentation(image, 0.8) {
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let uploadTask = imageReference.putData(imageData, metadata: metadata, completion: { (metadata, error) in
                if let metadata = metadata {
                    completionBlock(metadata.downloadURL(), nil)
                } else {
                    completionBlock(nil, error?.localizedDescription)
                }
            })
            uploadTask.observe(.progress, handler: { (snapshot) in
                guard let progress = snapshot.progress else {
                    return
                }
                if let pb = progressBar {
                    let percentage = (Float(progress.completedUnitCount) / Float(progress.totalUnitCount))
                    pb.progress = percentage
                    
                    if let pl = progressLabel {
                        let percentageInt = Int(percentage * 100)
                        pl.text = "\(percentageInt) %"
                    }
                }
            })
        } else {
            completionBlock(nil, "Image couldn't be converted to Data.")
        }
    }
    
    // get all ratings of a specific user
    func getRatingsByUserUID(userUID: String, completion: @escaping (_ rentings: [Rating]) -> Void){
        self.ratingsDBReference.queryOrdered(byChild: Rating.RATING_UID_KEY).queryEqual(toValue: userUID).observeSingleEvent(of: .value, with: {snapshot in
            var resultRatings:[Rating] = []
            for childRaw in snapshot.children {
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw), let rating = Rating.init(id: stringID, dict: dict) {
                    resultRatings.append(rating)
                } else {
                    print("getRatingsByUserUID: error while converting rating")
                }
            }
            completion(resultRatings)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // converts a firebase snapshot to a string ID (snapshot key) and a dictionary (snapshot value)
    func snapshotToStringIDAndDict(childRaw: Any) -> (String, [String:AnyObject])?{
        if let child = childRaw as? DataSnapshot, let dict = child.value as? [String:AnyObject] {
            return (child.key,dict)
        } else {
            return nil
        }
    }
    
    // converts a firebase snapshot to a int ID (snapshot key) and a dictionary (snapshot value)
    func snapshotToIntIDAndDict(childRaw: Any) -> (Int, [String:AnyObject])?{
        if let (stringID, dict) = snapshotToStringIDAndDict(childRaw: childRaw), let intID = Int(stringID) {
            return (intID,dict)
        } else {
            return nil
        }
    }
    
    // get a specific offering and the brand of the offered car
    func getOfferingWithBrandByOfferingID(offeringID: String, completion: @escaping (_ result: (Offering, Brand)?) -> Void){
        self.getOfferingByID(id: offeringID, completion: {offering in
            if let currentOffering = offering {
                // offering found -> get brand
                self.getBrandByID(id: currentOffering.brandID, completion: { offeringBrand in
                    completion((currentOffering, offeringBrand))
                })
            } else {
                // offering not found
                completion(nil)
            }
        })
    }
    
    // subscribe to the offerings of a user (returned with the brands of the offered cars)
    func subscribeToUsersOfferingsWithBrands(userUID: String, completion: @escaping (_ result: [(Offering, Brand)]) -> Void){
        self.offeringsDBReference.queryOrdered(byChild: Offering.OFFERING_USER_UID_KEY).queryEqual(toValue: userUID).observe(.value, with: {snapshot in
            var resultOfferings:[(Offering, Brand)] = []
            for childRaw in snapshot.children {
                if let (stringID, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw), let offering = Offering.init(id: stringID, dict: dict) {
                    self.getBrandByID(id: offering.brandID, completion: {offeringsBrand in
                        resultOfferings.append((offering, offeringsBrand))
                        if (resultOfferings.count == snapshot.childrenCount){
                            // last brand received -> fire callback
                            completion(resultOfferings)
                        }
                    })
                } else {
                    print("subscribeToUsersOfferingsWithBrands: error while converting offering")
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }

    }
    
    // get the features of a specific offering
    func getFeaturesForOffering(offeringID: String, completion: @escaping (_ offerings: [Feature]) -> Void){
        self.offeringsFeaturesDBReference.queryOrdered(byChild: DBConstants.PROPERTY_NAME_OFFERINGS_FEATURES_OFFERING).queryEqual(toValue: offeringID).observeSingleEvent(of: .value, with: { snapshot in
            var resultFeatures:[Feature] = []
            for childRaw in snapshot.children {
                let numberOfFeaturesForOffering = snapshot.childrenCount
                if let (_, dict) = self.snapshotToStringIDAndDict(childRaw: childRaw), let featureID = dict[DBConstants.PROPERTY_NAME_OFFERINGS_FEATURES_FEATURE] as? Int {
                    self.getFeatureByID(id: featureID, completion: {feature in
                        resultFeatures.append(feature)
                        if (resultFeatures.count == numberOfFeaturesForOffering) {
                            // added last feature -> fire callback
                            completion(resultFeatures)
                        }
                    })
                } else {
                    print("getFeaturesForOffering: error while converting offering's features")
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }

}

