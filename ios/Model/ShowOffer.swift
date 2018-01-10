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
    
    //todo: asynchrone rückgabe nötig?
    func getBasicDetails(offer: Offering) -> [String] {
        var basicDetailsDict: [String] = []
        
        basicDetailsDict.append(String(offer.seats))
        
        storageAPI.getVehicleTypeByID(id: offer.vehicleTypeID, completion: { (vehicleType) in
           basicDetailsDict.append(vehicleType.name)
        })
        
        storageAPI.getFuelByID(id: offer.fuelID, completion: { (fuel) in
            basicDetailsDict.append(fuel.name)
        })

        storageAPI.getGearByID(id: offer.gearID, completion: { (gear) in
            basicDetailsDict.append(gear.name)
        })
        
        return basicDetailsDict
    }
    
}
