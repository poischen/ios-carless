//
//  DBProvider.swift
//  ios
//
//  Created by Jelena Pranjic on 29.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol FetchData: class {
    func dataReceived(users: [User]);
}

class DBProvider {
    
    //create instance from this class
    private static let _instance = DBProvider();
    
    //value will not be instantiated until it is needed
    weak var delegate: FetchData?;
    
    //only this class can create an instance from this class
    private init() {}
    
    static var Instance: DBProvider {
        return _instance;
    }
    
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
                            
                            //append it in the empy array
                            users.append(newUser);
                        }
                    }
                }
            }
            self.delegate?.dataReceived(users: users);
        }
    }
    
    
}
