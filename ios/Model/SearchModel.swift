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
            filterFunctions.append({$0.seats >= minSeats})
        }
        if let city = filter.city {
            filterFunctions.append({$0.location == city})
        }
        if let maxConsumption = filter.maxConsumption {
            filterFunctions.append({$0.consumption <= maxConsumption})
        }
        if let minHP = filter.minHP {
            filterFunctions.append({$0.hp >= minHP})
        }
        if let gearshift = filter.gearshifts {
            filterFunctions.append({offering in
                return gearshift.contains {$0.name == offering.gear}
            })
        }
        if let brands = filter.brands {
            filterFunctions.append({offering in
                return brands.contains {$0.name == offering.brand}
            })
        }
        if let engines = filter.engines {
            filterFunctions.append({offering in
                return engines.contains {$0.name == offering.fuel}
            })
        }
        return filterFunctions
    }
    
}
