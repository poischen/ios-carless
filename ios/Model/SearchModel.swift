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
                    return self.arrayContainsArray(array: currentOfferingsFeatures, shouldContain: featureIDs)
                } else {
                    return false
                }
            })
        }
        return filterFunctions
    }
    
    func filterOfferingByDate(offering: Offering, rentings: [Renting], desiredDateInterval: DateInterval) -> Bool{
        // TODO: filter rentings beforehand
        let rentingsOfDesiredCar = rentings.filter {$0.inseratID == offering.id}
        return rentingsOfDesiredCar.reduce(true, {prevResult, renting in
            if (prevResult == false){
                // already found intersection of renting times -> renting not possible
                return false
            } else {
                let rentingDateInterval = DateInterval(start: renting.startDate, end: renting.endDate)
                if (rentingDateInterval.intersects(desiredDateInterval)){
                    return false
                } else {
                    return true
                }
                
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
    
    // TODO: remove
    /*
    func testFilterOfferingByDate(){
        // TESTING
        let offering = Offering(id: 1, brand: "BMW", basePrice: 10, consumption: 10, description: "yay", fuel: "Electric", gear: "Automatic", hp: 100, latitude: 10, location: "Berlin", longitude: 10, pictureURL: "yay", seats: 5, type: "asdf", featuresIDs: nil, vehicleTypeID: 0);
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let testDate11 = formatter.date(from: "01-01-2018")
        let testDate12 = formatter.date(from: "01-10-2018")
        let testDate13 = formatter.date(from: "01-11-2018")
        let testDate14 = formatter.date(from: "01-05-2018")
        
        let testDate21 = formatter.date(from: "01-10-2018")
        let testDate22 = formatter.date(from: "01-20-2018")
        let testDate23 = formatter.date(from: "01-30-2018")
        
        let desired = DateInterval(start: testDate11!, end: testDate12!)
        let desired2 = DateInterval(start: testDate11!, end: testDate13!)
        let desired3 = DateInterval(start: testDate11!, end: testDate11!)
        let desired4 = DateInterval(start: testDate14!, end: testDate14!)
        let desired5 = DateInterval(start: testDate21!, end: testDate22!)
        
        let rentings = [
            Renting(id: 1, inseratID: 1, userID: "asdf", startDate: testDate21!, endDate: testDate22!)
        ]
        let rentings2 = [
            Renting(id: 2, inseratID: 1, userID: "asdf", startDate: testDate11!, endDate: testDate11!)
        ]
        let rentings3 = [
            Renting(id: 3, inseratID: 1, userID: "asdf", startDate: testDate14!, endDate: testDate14!)
        ]
        let rentings4 = [
            Renting(id: 4, inseratID: 1, userID: "asdf", startDate: testDate11!, endDate: testDate12!)
        ]
        let rentings5 = [
            Renting(id: 5, inseratID: 1, userID: "asdf", startDate: testDate11!, endDate: testDate12!),
            Renting(id: 6, inseratID: 1, userID: "asdf", startDate: testDate22!, endDate: testDate23!)
        ]
        
        // end day of desired is start date of renting
        print("test1:" + String(filterOfferingByDate(offering: offering, rentings: rentings, desiredDateInterval: desired)) + "(should be true)")
        // intersection of more than one day
        print("test2:" + String(filterOfferingByDate(offering: offering, rentings: rentings, desiredDateInterval: desired2)) + "(should be false)")
        // two one day bookings on the same day:
        print("test3:" + String(filterOfferingByDate(offering: offering, rentings: rentings2, desiredDateInterval: desired3)) + "(should be false)")
        // one day booking on the start day of desired
        print("test4:" + String(filterOfferingByDate(offering: offering, rentings: rentings2, desiredDateInterval: desired)) + "(should be false)")
        // one day reserved in the middle of desired
        print("test5:" + String(filterOfferingByDate(offering: offering, rentings: rentings3, desiredDateInterval: desired)) + "(should be false)")
        // one day desired in the middle of reserved
        print("test6:" + String(filterOfferingByDate(offering: offering, rentings: rentings4, desiredDateInterval: desired4)) + "(should be false)")
        // one day overlap at start and end of desired
        print("test7:" + String(filterOfferingByDate(offering: offering, rentings: rentings5, desiredDateInterval: desired5)) + "(should be true)")
    }*/
    
    func arrayContainsArray(array: [Int], shouldContain: [Int]) -> Bool{
        let selfSet = Set(array)
        return !shouldContain.contains { !selfSet.contains($0) }
    }
    
    
    
}
