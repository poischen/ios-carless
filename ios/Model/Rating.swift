//
//  LessorRating.swift
//  ios
//
//  Created by Konrad Fischer on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class Rating: DictionaryConvertibleEditable {
    
    // constants for the dictionary keys
    static let RATING_UID_KEY = "userUID"
    static let RATING_EXPLANATION = "ratingExplanation"
    static let RATING_RATING = "rating"
    
    convenience required init?(id: String?, dict: [String : AnyObject]) {
        guard let ratingUserUID = dict[Rating.RATING_UID_KEY] as? String,
              let ratingExplanation = dict[Rating.RATING_EXPLANATION] as? String,
              let ratingRating = dict[Rating.RATING_RATING] as? Int else {
            return nil
        }
        // TODO: use id?
        self.init(id: id, userUID: ratingUserUID, explanation: ratingExplanation, rating: ratingRating)
    }
    
    var id: String?
    let userUID: String
    let explanation: String
    let rating: Int
    
    init(id: String?, userUID: String, explanation: String, rating: Int) {
        self.userUID = userUID
        self.explanation = explanation
        self.rating = rating
        self.id = id
    }
    
    var dict: [String : AnyObject] {
        return [
            Rating.RATING_UID_KEY: self.userUID as AnyObject,
            Rating.RATING_EXPLANATION: self.explanation as AnyObject,
            Rating.RATING_RATING: self.rating as AnyObject
        ]
    }
}
