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
// TODO: don't use forced typecasting -> handle errors gracefully

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
    private let gearsDBReference: DatabaseReference
    private let brandsDBReference: DatabaseReference
    private let fuelDBReference: DatabaseReference
    
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
        Database.database().isPersistenceEnabled = true
        fireBaseDBAccess = Database.database().reference()
        notificationCenter = NotificationCenter.default
        self.offeringsDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_OFFERINGS)
        self.rentingsDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_RENTINGS)
        self.featuresDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_FEATURES)
        self.offeringsFeaturesDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_OFFERINGS_FEATURES)
        self.vehicleTypesDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_VEHICLE_TYPES)
        self.gearsDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_GEARS)
        self.brandsDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_BRANDS)
        self.fuelDBReference = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_FUELS)
        
        // tryong to avoid caching problems by keeping references synced until queried for the first time
        // TODO: find better solution?
        self.offeringsDBReference.keepSynced(true)
        self.rentingsDBReference.keepSynced(true)
        self.featuresDBReference.keepSynced(true)
        self.offeringsFeaturesDBReference.keepSynced(true)
        self.vehicleTypesDBReference.keepSynced(true)
        self.gearsDBReference.keepSynced(true)
        self.brandsDBReference.keepSynced(true)
        self.fuelDBReference.keepSynced(true)
        self.usersRef.keepSynced(true)
    }
    
    func getOfferings(completion: @escaping (_ offerings: [Offering]) -> Void){
        self.offeringsDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultOfferings:[Offering] = []
            for childRaw in snapshot.children {
                let child = childRaw as! DataSnapshot
                let dict = child.value as! [String:AnyObject]
                let offering = Offering.init(id: Int(child.key)!, dict: dict)! // TODO: catch nil here
                resultOfferings.append(offering)
            }
            completion(resultOfferings)
            //self.offeringsDBReference.keepSynced(false) // fix for caching problems
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getFeatures(completion: @escaping (_ features: [Feature]) -> Void){
        self.featuresDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultFeatures:[Feature] = []
            for childRaw in snapshot.children {
                let child = childRaw as! DataSnapshot
                let dict = child.value as! [String:AnyObject]
                let feature = Feature.init(id: Int(child.key)!, dict: dict)!
                resultFeatures.append(feature)
            }
            completion(resultFeatures)
            //self.featuresDBReference.keepSynced(false) // fix for caching problems
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // this method does not follow the dictionary convertible scheme as the offerings' features are best reprensented by a map and not by an object
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
                    var prevOfferingFeatures = resultOfferingsFeatures[offeringID]!
                    prevOfferingFeatures.append(featureID)
                    resultOfferingsFeatures[offeringID] = prevOfferingFeatures
                } else {
                    // first feature for this offering -> initialise array
                    resultOfferingsFeatures[offeringID] = [featureID]
                }
            }
            completion(resultOfferingsFeatures)
            //self.offeringsFeaturesDBReference.keepSynced(false) // fix for caching problems
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getRentings(completion: @escaping (_ rentings: [Renting]) -> Void){
        self.rentingsDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultRentings:[Renting] = []
            for childRaw in snapshot.children {
                let child = childRaw as! DataSnapshot
                let dict = child.value as! [String:AnyObject]
                let renting = Renting.init(id: Int(child.key)!, dict: dict)!
                resultRentings.append(renting)
            }
            completion(resultRentings)
            //self.rentingsDBReference.keepSynced(false) // fix for caching problems
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getVehicleTypes(completion: @escaping (_ vehicleTypes: [VehicleType]) -> Void){
        self.vehicleTypesDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultTypes:[VehicleType] = []
            for childRaw in snapshot.children {
                let child = childRaw as! DataSnapshot
                let dict = child.value as! [String:AnyObject]
                let type = VehicleType.init(id: Int(child.key)!, dict: dict)!
                resultTypes.append(type)
            }
            completion(resultTypes)
            //self.vehicleTypesDBReference.keepSynced(false) // fix for caching problems
        }) { (error) in
            print(error.localizedDescription)
        }
        completion([])
    }
    
    func getBrands(completion: @escaping (_ brands: [Brand]) -> Void){
        self.brandsDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultBrands:[Brand] = []
            for childRaw in snapshot.children {
                let child = childRaw as! DataSnapshot
                let dict = child.value as! [String:AnyObject]
                let brand = Brand.init(id: Int(child.key)!, dict: dict)!
                resultBrands.append(brand)
            }
            completion(resultBrands)
            //self.brandsDBReference.keepSynced(false) // fix for caching problems
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getBrandsAsMap(completion: @escaping (_ brands: [Int:Brand]) -> Void){
        self.brandsDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultBrands:[Int:Brand] = [:]
            for childRaw in snapshot.children {
                let child = childRaw as! DataSnapshot
                let dict = child.value as! [String:AnyObject]
                let brand = Brand.init(id: Int(child.key)!, dict: dict)!
                resultBrands.updateValue(brand, forKey: brand.id)
            }
            completion(resultBrands)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getFuels(completion: @escaping (_ fuels: [Fuel]) -> Void){
        self.fuelDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultFuels:[Fuel] = []
            // TODO: avoid code duplication here
            for childRaw in snapshot.children {
                let child = childRaw as! DataSnapshot
                let dict = child.value as! [String:AnyObject]
                let fuel = Fuel.init(id: Int(child.key)!, dict: dict)!
                resultFuels.append(fuel)
            }
            completion(resultFuels)
            //self.fuelDBReference.keepSynced(false) // fix for caching problems
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getFuelsAsMap(completion: @escaping (_ fuels: [Int:Fuel]) -> Void){
        self.fuelDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultFuels:[Int:Fuel] = [:]
            for childRaw in snapshot.children {
                let child = childRaw as! DataSnapshot
                let dict = child.value as! [String:AnyObject]
                let fuel = Fuel.init(id: Int(child.key)!, dict: dict)!
                resultFuels.updateValue(fuel, forKey: fuel.id)
            }
            completion(resultFuels)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getGears(completion: @escaping (_ gears: [Gear]) -> Void){
        self.gearsDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultGears:[Gear] = []
            for childRaw in snapshot.children {
                let child = childRaw as! DataSnapshot
                let dict = child.value as! [String:AnyObject]
                let gear = Gear.init(id: Int(child.key)!, dict: dict)!
                resultGears.append(gear)
            }
            completion(resultGears)
            //self.gearsDBReference.keepSynced(false) // fix for caching problems
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getGearsAsMap(completion: @escaping (_ gears: [Int:Gear]) -> Void){
        self.gearsDBReference.observeSingleEvent(of: .value, with: { snapshot in
            var resultGears:[Int:Gear] = [:]
            for childRaw in snapshot.children {
                let child = childRaw as! DataSnapshot
                let dict = child.value as! [String:AnyObject]
                let gear = Gear.init(id: Int(child.key)!, dict: dict)!
                resultGears.updateValue(gear, forKey: gear.id)
            }
            completion(resultGears)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //stores User in Database
    func saveUser(withID: String, name: String, email: String, rating: Float, profileImg: String){
        let data: Dictionary<String, Any> = [Constants.NAME: name, Constants.EMAIL: email, Constants.RATING: rating, Constants.PROFILEIMG: profileImg];
        
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
                        if let name = userData[Constants.NAME] as? String, let rating = userData[Constants.RATING] as? Float, let profileImgUrl = userData[Constants.PROFILEIMG] as? String {
                            
                            let id = key as! String;
                            let newUser = User(id: id, name: name, rating: rating, profileImgUrl: profileImgUrl);
                            
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

