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
    private let lessorRatings: DatabaseReference
    
    //value will not be instantiated until it is needed
    weak var delegate: FetchData?;
    
    var userName = "";
    
    //returns Project URL from Firebase
    // TODO: merge database references
    var dbRef: DatabaseReference {
        return Database.database().reference();
    }
    
    // TODO: cache users?
    var usersRef: DatabaseReference{
        return dbRef.child(DBConstants.USERS);
    }
    
    var messagesRef: DatabaseReference {
        return dbRef.child(DBConstants.MESSAGES);
    }
    
    var mediaMessagesRef: DatabaseReference{
        return dbRef.child(DBConstants.MEDIA_MESSAGES);
    }
    
    //where media files are stored
    var storageRef: StorageReference {
        return Storage.storage().reference(forURL: "gs://ioscars-32e69.appspot.com");
    }
    
    var imageStorageRef: StorageReference {
        return storageRef.child(DBConstants.IMAGE_STORAGE);
    }
    
    var videoStorageRef: StorageReference {
        return storageRef.child(DBConstants.VIDEO_STORAGE);
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
        self.lessorRatings = self.fireBaseDBAccess.child(DBConstants.PROPERTY_NAME_RATINGS)
        
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
        self.lessorRatings.keepSynced(true)
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
    
    func getOfferingByID(id: Int, completion: @escaping (_ offering: Offering) -> Void){
        self.offeringsDBReference.queryOrderedByKey().queryEqual(toValue: String(id)).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                let childRaw = snapshot.children.nextObject()
                if let child = childRaw as? DataSnapshot, let dict = child.value as? [String:AnyObject] {
                    let offeringID = Int(child.key)! // not ideal but for some reason typecasting with "?" doesn't work
                    if let offering = Offering.init(id: offeringID, dict: dict) {
                        completion(offering)
                    } else {
                        print("error in get getOfferingByID")
                    }
                } else {
                    print("error in get getOfferingByID")
                }
            } else {
                print("no offering or more than one offering found")
            }
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
                        print("error in getOfferingsFeatures")
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
    
    // not using this anymore
    // TODO: remove
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
    
    func getBrandByID(id: Int, completion: @escaping (_ brand: Brand) -> Void){
        self.brandsDBReference.queryOrderedByKey().queryEqual(toValue: String(id)).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                let childRaw = snapshot.children.nextObject()
                if let child = childRaw as? DataSnapshot, let dict = child.value as? [String:AnyObject] {
                    let brandID = Int(child.key)! // not ideal but for some reason typecasting with "?" doesn't work
                    if let brand = Brand.init(id: brandID, dict: dict) {
                        completion(brand)
                    } else {
                        print("error in get getBrandByID")
                    }
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
    
    // not using this anymore
    // TODO: remove
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
    
    func getFuelByID(id: Int, completion: @escaping (_ fuel: Fuel) -> Void){
        self.fuelDBReference.queryOrderedByKey().queryEqual(toValue: String(id)).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                let childRaw = snapshot.children.nextObject()
                if let child = childRaw as? DataSnapshot, let dict = child.value as? [String:AnyObject] {
                    let fuelID = Int(child.key)! // not ideal but for some reason typecasting with "?" doesn't work
                    if let fuel = Fuel.init(id: fuelID, dict: dict) {
                        completion(fuel)
                    } else {
                        print("error in get getFuelByID")
                    }
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
    
    // not using this anymore
    // TODO: remove
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
    
    func getGearByID(id: Int, completion: @escaping (_ gear: Gear) -> Void){
        self.gearsDBReference.queryOrderedByKey().queryEqual(toValue: String(id)).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                let childRaw = snapshot.children.nextObject()
                if let child = childRaw as? DataSnapshot, let dict = child.value as? [String:AnyObject] {
                    let gearID = Int(child.key)! // not ideal but for some reason typecasting with "?" doesn't work
                    if let gear = Gear.init(id: gearID, dict: dict) {
                        completion(gear)
                    } else {
                        print("error in get getGearByID")
                    }
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
    
    func saveRating(rating: Rating){
        let ratingAsDict = rating.dict
        self.lessorRatings.childByAutoId().setValue(ratingAsDict)
    }
    
    func updateUser(user: User){
        let userAsDict = user.dict
        self.usersRef.child(user.id).setValue(userAsDict)
    }
    
    //stores User in Database
    func saveUser(withID: String, name: String, email: String, rating: Float, profileImg: String){
        let data: Dictionary<String, Any> = [DBConstants.NAME: name, DBConstants.EMAIL: email, DBConstants.RATING: rating, DBConstants.PROFILEIMG: profileImg];
        
        usersRef.child(withID).setValue(data);
    }
    
  /*  func getUsers() {
        
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
                        if let name = userData[DBConstants.NAME] as? String, let rating = userData[DBConstants.RATING] as? Float, let profileImgUrl = userData[DBConstants.PROFILEIMG] as? String {
                            
                            let id = key as! String;
                            let newUser = User(id: id, name: name, rating: rating, profileImgUrl: profileImgUrl,);
                            
                            //append it in the empty array
                            users.append(newUser);
                        }
                    }
                }
            }
            self.delegate?.dataReceived(users: users);
        }
    }*/
    
    func getUsers(completion: @escaping (_ users: [User]) -> Void){
        self.usersRef.observeSingleEvent(of: .value, with: { snapshot in
            var resultUsers:[User] = []
            for childRaw in snapshot.children {
                let child = childRaw as! DataSnapshot
                let dict = child.value as! [String:AnyObject]
                let user = User.init(id: child.key, dict: dict)!
                resultUsers.append(user)
            }
            completion(resultUsers)
            //self.gearsDBReference.keepSynced(false) // fix for caching problems
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getUserByUID(UID: String, completion: @escaping (_ user: User) -> Void){
        self.usersRef.queryOrderedByKey().queryEqual(toValue: UID).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.childrenCount == 1 {
                if let userSnapshot = snapshot.children.nextObject() as? DataSnapshot, let userData = userSnapshot.value as? NSDictionary{
                        if let userName = userData[DBConstants.NAME] as? String, let userRating = userData[DBConstants.RATING] as? Float, let userPic = userData[DBConstants.PROFILEIMG] as? String,
                            let numberOfRatings = userData[User.NUMBER_OF_RATINGS] as? Int,
                        let email = userData[User.EMAIL] as? String {
                            completion(User(id: UID, name: userName, email: email, rating: userRating, profileImgUrl: userPic, numberOfRatings: numberOfRatings ))
                            return
                        }
                }
                // retun not executed -> something went wrong -> print error
                print("error in get getUserByUID")
            } else {
                print("no user or more than one user found")
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    //gets UserID in Firebase
    func userID() -> String {
        return Auth.auth().currentUser!.uid;
    }
    
    
}

