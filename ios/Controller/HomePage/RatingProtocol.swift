//
//  RatingProtocol.swift
//  ios
//
//  Created by Konrad Fischer on 21.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation

protocol RatingProtocol {
    func rateLessor(renting: Renting)
    func rateLessee(renting: Renting, lesseeUser: User)
    func goToProfile(user: User)
    func goToOffer(offer: Offering)
}
