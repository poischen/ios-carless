//
//  SearchModel.swift
//  ios
//
//  Created by Konrad Fischer on 19.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class SearchModel {
    private let FILTER_RADIUS_METERS:Double = 12000.0
    
    private let storageAPI: StorageAPI
    static let shared: SearchModel = SearchModel()
    
    // this class is a singleton -> private constructor
    private init() {
        self.storageAPI = StorageAPI.shared
    }
    
    // gets offerings from the DB and returns the ones that match the filter criteria
    func getFilteredOfferings(filter: Filter, completion: @escaping (_ offerings: [Offering]) -> Void) {
        self.storageAPI.getOfferings(completion: {offerings in
            // get rentings from DB as they're necessary to determine whether a car is still free on the desired date
            self.storageAPI.getRentings(completion: {rentings in
                if filter.featureIDs != nil {
                    // get the offerings' features from the DB as they're necessary to determine whether an offering has the desired features (if the user wants to filter by features)
                    self.storageAPI.getOfferingsFeatures(completion: {offeringsFeatures in
                        // convert filter object to filter function
                        let filterFunctions = self.filterToFilterFunctions(filter: filter, rentings: rentings, offeringsFeatures: offeringsFeatures)
                        /*
                         filter offerings by applying reduce to the filter functions:
                         - start with all offerings
                         - in each step: check whether an offering satisfies the current filter function, only keep the offerings that do as candidates to satisfy the next filter
                         */
                        let filteredOfferings = filterFunctions.reduce(offerings) { accu, currFilter in
                            return accu.filter(currFilter)
                        }
                        completion(filteredOfferings)
                    })
                } else {
                    // convert filter object to filter function
                    let filterFunctions = self.filterToFilterFunctions(filter: filter, rentings: rentings, offeringsFeatures: nil)
                    // filter offerings by applying reduce to the filter functions (see above)
                    let filteredOfferings = filterFunctions.reduce(offerings) { accu, currFilter in
                        return accu.filter(currFilter)
                    }
                    completion(filteredOfferings)
                }
            })
        });
    }
    
    /* converts a filter object to an array of filter functions that take an offering and return whether is satisfies the filter criterion
     IMPORTANT: features filter function is only added to the array if offeringsFeatures is not nill and the featureIDs attribute in the filter object is set
    */
    func filterToFilterFunctions(filter: Filter, rentings: [Renting], offeringsFeatures: [String:[Int]]?) -> [(_ offering: Offering) -> Bool] {
        var filterFunctions:[(_ offering: Offering) -> Bool] = []
        // add brand ID filter function if filter criterion is set
        if let brandIDs = filter.brandIDs {
            filterFunctions.append {brandIDs.contains($0.brandID)}
        }
        // add max consumtion filter function if filter criterion is set
        if let maxConsumption = filter.maxConsumption {
            filterFunctions.append({$0.consumption <= maxConsumption})
        }
        // add max fuel filter function if filter criterion is set
        if let fuelIDs = filter.fuelIDs {
            filterFunctions.append {fuelIDs.contains($0.fuelID)}
        }
        // add gear filter function if filter criterion is set
        if let gearIDs = filter.gearIDs {
            filterFunctions.append {gearIDs.contains($0.gearID)}
        }
        // add HP filter function if filter criterion is set
        if let minHP = filter.minHP {
            filterFunctions.append {$0.hp >= minHP}
        }
        // add price filter function if filter criterion is set
        if let maxPrice = filter.maxPrice {
            filterFunctions.append {$0.basePrice <= maxPrice}
        }
        // add seats filter function if filter criterion is set
        if let minSeats = filter.minSeats {
            filterFunctions.append {$0.seats >= minSeats}
        }
        // add vehicle type filter function if filter criterion is set
        if let vehicleTypeIDs = filter.vehicleTypeIDs {
            filterFunctions.append {vehicleTypeIDs.contains($0.vehicleTypeID)} // check whether vehicle's type is one of the desired types
        }
        // add date filter function if filter criterion is set
        if let desiredDateInterval = filter.dateInterval {
            filterFunctions.append({offering in
                self.filterOfferingByDate(offering: offering, rentings: rentings, desiredDateInterval: desiredDateInterval)
            })
        }
        // add feature filter function if filter criterion is set AND if the offerings' features were given to the function
        if let currentOfferingsFeatures = offeringsFeatures, let featureIDs = filter.featureIDs {
            filterFunctions.append({offering in
                if let offeringID = offering.id {
                    if let currentOfferingsFeatures = currentOfferingsFeatures[offeringID] {
                        //offering has features -> test whether it has all desired features
                        return SearchModel.arrayContainsArray(baseArray: currentOfferingsFeatures, shouldContain: featureIDs)
                    } else {
                        return false
                    }
                } else {
                    // offerings without an ID are invalid -> don't return them
                    return false
                }
            })
        }
        
        // add location filter function if location criterion is set
        if let desiredPlaceLocation = filter.placePoint {
            filterFunctions.append {
                let distance = $0.locationPoint.distanceToPoint(otherPoint: desiredPlaceLocation)
                return distance <= self.FILTER_RADIUS_METERS
            }
        }
        
        return filterFunctions
    }
    
    func filterOfferingByDate(offering: Offering, rentings: [Renting], desiredDateInterval: DateInterval) -> Bool{
        // we only need the rentings of the desired offering meaning ...
        let rentingsOfDesiredCar = rentings.filter {renting in
            if renting.id != nil, let offeringID = offering.id {
                // ... the rentings that have the same offering ID as the offering
                return renting.inseratID == offeringID
            } else {
                return false
            }
        }
        // reduce rentings to a boolean stating whether a renting in desiredDateInterval is possible
        return rentingsOfDesiredCar.reduce(true, {prevResult, currentRenting in
            if (prevResult == false){
                // already found intersection of renting times -> renting not possible
                return false
            } else {
                // no intersection found yet -> check whether current renting and desired date interval intersect
                let rentingDateInterval = DateInterval(start: currentRenting.startDate, end: currentRenting.endDate)
                return !rentingDateInterval.intersects(desiredDateInterval)
            }
        })
    }
    
    // HELPER FUNCTIONS
    
    static func arrayContainsArray(baseArray: [Int], shouldContain: [Int]) -> Bool{
        // convert baseArray to a set
        let selfSet = Set(baseArray)
        // shouldContain contains an element that the base array doesn't contain -> baseArray doesn't contain shouldContain
        return !shouldContain.contains { !selfSet.contains($0) }
    }
}
