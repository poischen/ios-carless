//
//  User.swift
//  ios
//
//  Created by Jelena Pranjic on 29.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class User {
    
    private var _name = "";
    private var _id = "";
    
    //create Users when fetching them from Database
    init(id: String, name: String){
        _id = id;
        _name = name;
        
    }
    
    var name: String {
        //getter
        return _name;
        
    }
    
    var id: String {
        return _id;
    }
}
