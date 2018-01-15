//
//  ShowOffer.swift
//  ios
//
//  Created by admin on 07.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation

class ShowOffer {
        
        let storageAPI = StorageAPI.shared
        
        func getBasicDetails(offer: Offering, completion: @escaping (_ basicDetails: [String]?) -> Void) {
            var basicDetailsDict: [String]? = []
            
            basicDetailsDict!.append(String(offer.seats))
            
            storageAPI.getVehicleTypeByID(id: offer.vehicleTypeID, completion: { (vehicleType) in
                basicDetailsDict!.append(vehicleType.name)
                
                self.storageAPI.getFuelByID(id: offer.fuelID, completion: { (fuel) in
                    basicDetailsDict!.append(fuel.name)
                    
                    self.storageAPI.getGearByID(id: offer.gearID, completion: { (gear) in
                        basicDetailsDict!.append(gear.name)
                        completion(basicDetailsDict)
                    })
                })
            })
            
        }
}
