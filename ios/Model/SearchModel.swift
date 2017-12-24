//
//  SearchModel.swift
//  ios
//
//  Created by Konrad Fischer on 19.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class SearchModel {
    private let storageAPI: StorageAPI
    
    init() {
        self.storageAPI = StorageAPI.shared
    }
    
    func getFilteredOfferings(filter: Filter, completion: @escaping (_ offerings: [Offering]) -> Void) {
        self.storageAPI.getOfferings(completion: {offerings in
            self.storageAPI.getRentings(completion: {rentings in
                self.storageAPI.getOfferingsFeatures(completion: {offeringsFeatures in
                    let filterFunctions = self.filterToFilterFunctions(filter: filter, rentings: rentings, offeringsFeatures: offeringsFeatures)
                    let filteredOfferings = filterFunctions.reduce(offerings) { accu, currFilter in
                        return accu.filter(currFilter)
                    }
                    completion(filteredOfferings)
                })
            })
        });
    }
    
    func filterToFilterFunctions(filter: Filter, rentings: [Renting], offeringsFeatures: [Int:[Int]]) -> [(_ offering: Offering) -> Bool] {
        var filterFunctions:[(_ offering: Offering) -> Bool] = []
        // TODO: find most efficient order for filter functions
        if let brandIDs = filter.brandIDs {
            filterFunctions.append {brandIDs.contains($0.brandID)}
        }
        if let maxConsumption = filter.maxConsumption {
            filterFunctions.append({$0.consumption <= maxConsumption})
        }
        if let fuelIDs = filter.fuelIDs {
            filterFunctions.append {fuelIDs.contains($0.fuelID)}
        }
        if let gearIDs = filter.gearIDs {
            filterFunctions.append {gearIDs.contains($0.gearID)}
        }
        if let minHP = filter.minHP {
            filterFunctions.append {$0.hp >= minHP}
        }
        if let location = filter.location {
            filterFunctions.append {$0.location == location}
        }
        if let maxPrice = filter.maxPrice {
            filterFunctions.append {$0.basePrice <= maxPrice}
        }
        if let minSeats = filter.minSeats {
            filterFunctions.append {$0.seats >= minSeats}
        }
        if let vehicleTypeIDs = filter.vehicleTypeIDs {
            filterFunctions.append {vehicleTypeIDs.contains($0.vehicleTypeID)}
        }
        if let desiredDateInterval = filter.dateInterval {
            filterFunctions.append({offering in
                self.filterOfferingByDate(offering: offering, rentings: rentings, desiredDateInterval: desiredDateInterval)
            })
        }
        if let featureIDs = filter.featureIDs {
            filterFunctions.append({offering in
                if let currentOfferingsFeatures = offeringsFeatures[offering.id] {
                    //offering has features -> test whether it has  all desired features
                    return SearchModel.arrayContainsArray(array: currentOfferingsFeatures, shouldContain: featureIDs)
                } else {
                    return false
                }
            })
        }
        return filterFunctions
    }
    
    func filterOfferingByDate(offering: Offering, rentings: [Renting], desiredDateInterval: DateInterval) -> Bool{
        // renting is not possible if the desired return time is later than the offering's return time
        // or the desired renting time is earlier than the offering's renting time
        // TODO: filter rentings beforehand
        let rentingsOfDesiredCar = rentings.filter {$0.inseratID == offering.id}
        return rentingsOfDesiredCar.reduce(true, {prevResult, renting in
            if (prevResult == false){
                // already found intersection of renting times -> renting not possible
                return false
            } else {
                let rentingDateInterval = DateInterval(start: renting.startDate, end: renting.endDate)
                return !rentingDateInterval.intersects(desiredDateInterval)
            }
        })
    }
    
    /* func filterOfferingByDateOld(offering: Offering, rentings: [Renting], desiredDateInterval: DateInterval) -> Bool{
        // TODO: filter rentings beforehand
        let rentingsOfDesiredCar = rentings.filter {$0.inseratID == offering.id}
        return rentingsOfDesiredCar.reduce(true, {prevResult, renting in
            if (prevResult == false){
                // already found intersection of reting times -> renting not possible
                return false
            } else {
                let rentingDateInterval = DateInterval(start: renting.startDate, end: renting.endDate)
                if (rentingDateInterval.intersects(desiredDateInterval)){
                    let intersection = desiredDateInterval.intersection(with: rentingDateInterval)
                    if (intersection!.duration == 0){
                        // intersection with duration 0 -> intervals only overlap on one day
                        if ((desiredDateInterval.start == rentingDateInterval.end || desiredDateInterval.end == rentingDateInterval.start) && rentingDateInterval.duration > 0){
                            // allow desire date interval and renting to overlap at the end or the start of the desired date interval as a car can be returned in the morning and picked up in the evening and vice versa
                            // make sure that the renting is not a one day renting as the car would not be ready for the next customer at the end of that day
                            return true
                        } else {
                            // intervals overlap but not at the start or the end -> renting not possible
                            return false
                        }
                    } else {
                        // intersection is larger than one day -> renting not possible
                        return false
                    }
                } else {
                    return true
                }
                
            }
        })
    } */
    
    // HELPER FUNCTIONS
    
    // TODO: is this function necessary? we could just use sets for the data
    static func arrayContainsArray(array: [Int], shouldContain: [Int]) -> Bool{
        let selfSet = Set(array)
        return !shouldContain.contains { !selfSet.contains($0) }
    }
}
