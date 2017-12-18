//
//  CarLocation.swift
//  show_inserat
//
//  Created by admin on 13.12.17.
//  Copyright © 2017 ioscars. All rights reserved.
//

import MapKit

class CarLocation: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    
    init(locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = "Fetch your car here"
        self.locationName = locationName
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}
