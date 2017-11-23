//
//  SearchModel.swift
//  ios
//
//  Created by Konrad Fischer on 19.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class SearchModel {
    private let notificationCenter: NotificationCenter
    private let storageAPI: StorageAPI
    
    init() {
        self.notificationCenter = NotificationCenter.default
        self.storageAPI = StorageAPI.shared
    }
    
    func getFilteredOfferings(filterFunctions: [(_ offering: Offering) -> Bool], completion: @escaping (_ offerings: [Offering]) -> Void) {
        storageAPI.getOfferings(completion: {offerings in
            let filteredOfferings = filterFunctions.reduce(offerings) { accu, currFilter in
                return accu.filter(currFilter)
            }
            completion(filteredOfferings)
        });
    }
    
}
