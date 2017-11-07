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
        fireBaseDBAccess.child("carModels").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.valueInExportFormat() as! NSDictionary
            print(value)
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
