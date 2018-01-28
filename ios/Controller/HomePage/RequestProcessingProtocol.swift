//
//  RequestCellProtocol.swift
//  ios
//
//  Created by Konrad Fischer on 14.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation

protocol RequestProcessingProtocol {
    func acceptRequest(renting: Renting)
    func denyRequest(renting: Renting)
    func goToProfile(user: User)
}
