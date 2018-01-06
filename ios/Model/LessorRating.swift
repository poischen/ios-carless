//
//  LessorRating.swift
//  ios
//
//  Created by Konrad Fischer on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class LessorRating: DictionaryConvertible {
    
    // constants for the dictionary keys
    static let LESSOR_RATING_UID_KEY = "userUID"
    static let LESSOR_RATING_EXPLANATION = "ratingExplanation"
    static let LESSOR_RATING_RATING = "rating"
    
    convenience required init?(id: Int, dict: [String : AnyObject]) {
        guard let ratingUserUID = dict[LessorRating.LESSOR_RATING_UID_KEY] as? String,
              let ratingExplanation = dict[LessorRating.LESSOR_RATING_EXPLANATION] as? String,
              let ratingRating = dict[LessorRating.LESSOR_RATING_RATING] as? Int else {
            return nil
        }
        self.init(id: id, userUID: ratingUserUID, explanation: ratingExplanation, rating: ratingRating)
    }
    
    let id: Int
    let userUID: String
    let explanation: String
    let rating: Int
    
    init(id: Int, userUID: String, explanation: String, rating: Int) {
        self.id = id
        self.userUID = userUID
        self.explanation = explanation
        self.rating = rating
    }
    
    var dict: [String : AnyObject] {
        return [
            LessorRating.LESSOR_RATING_UID_KEY: self.userUID as AnyObject,
            LessorRating.LESSOR_RATING_EXPLANATION: self.explanation as AnyObject,
            LessorRating.LESSOR_RATING_RATING: self.rating as AnyObject
        ]
    }
}