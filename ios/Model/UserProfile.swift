//
//  UserProfile.swift
//  show_inserat
//
//  Created by admin on 12.12.17.
//  Copyright © 2017 ioscars. All rights reserved.
//

import Foundation

class UserProfile {
    
    let id: String
    let name: String
    let profileImgUrl: String
    let rating: Float
    
    init(id: String, name: String, profileImgUrl: String, rating: Float) {
        self.id = id
        self.name = name
        self.profileImgUrl = profileImgUrl
        self.rating = rating
    }
}

