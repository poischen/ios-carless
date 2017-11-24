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
    
    func getFilteredOfferings(filter: Filter, completion: @escaping (_ offerings: [Offering]) -> Void) {
        storageAPI.getOfferings(completion: {offerings in
            let filteredOfferings = self.filterToFilterFunctions(filter: filter).reduce(offerings) { accu, currFilter in
                return accu.filter(currFilter)
            }
            completion(filteredOfferings)
        });
    }
    
    func filterToFilterFunctions(filter: Filter) -> [(_ offering: Offering) -> Bool] {
        var filterFunctions:[(_ offering: Offering) -> Bool] = []
        if let minSeats = filter.minSeats {
            filterFunctions.append({offering in return offering.seats >= minSeats})
        }
        if let city = filter.city {
            filterFunctions.append({offering in return offering.location == city})
        }
        return filterFunctions
    }
    
}