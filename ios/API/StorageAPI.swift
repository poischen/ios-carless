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
    
    private init() {
        fireBaseDBAccess = Database.database().reference()
    }
    
    func getCar() {
        self.fireBaseDBAccess.child("carModels").setValue(["1": "Model 1"])
        self.fireBaseDBAccess.child("carModels").setValue(["2": "Model 2"])
        self.fireBaseDBAccess.child("carModels").setValue(["3": "Model 3"])
        self.fireBaseDBAccess.child("test").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            print(value)            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        self.fireBaseDBAccess.child("carModels").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            print(value)
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
