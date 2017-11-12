//
//  StorageAPI.swift
//  ios
//
//  Created by Konrad Fischer on 07.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

// singleton class for access to Firebase and maybe to local storage in the future

final class StorageAPI {
    static let shared = StorageAPI()
    private let fireBaseDBAccess: DatabaseReference!
    private let notificationCenter: NotificationCenter
    
    private init() {
        fireBaseDBAccess = Database.database().reference()
        notificationCenter = NotificationCenter.default
    }
    
    func getCars(){
        fireBaseDBAccess.child("cars").observeSingleEvent(of: .value, with: { (snapshot) in
            let photo = UIImage(named: "car1")
            let receivedData = snapshot.valueInExportFormat() as! NSDictionary
            var resultCars:[Car] = [Car]()
            for (cardID, rawCarData) in receivedData {
                let carData:NSDictionary = rawCarData as! NSDictionary
                let carModel:Int = carData["model"] as! Int
                let carGearshift:Int = carData["gearshift"] as! Int
                let carFuel:Int = carData["fuel"] as! Int
                let carMileage:Int = carData["mileage"] as! Int
                let carSeats:Int = carData["seats"] as! Int
                
                let newCar:Car = Car(model: carModel, gearshift: carGearshift, mileage: Double(carMileage), fuel: carFuel, seats: carSeats, extras: ["Navi", "Kindersitz"], location: "München", photo: photo , rating: 5) as! Car
                resultCars.append(newCar)
            }
            self.notificationCenter.post(
                name: Notification.Name(rawValue:"sendCars"),
                object: nil,
                userInfo: ["cars":resultCars]
            )
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getExtras(){
        fireBaseDBAccess.child("extras").observeSingleEvent(of: .value, with: { (snapshot) in
            let receivedData = snapshot.valueInExportFormat() as! NSDictionary
            var resultExtras:[Extra] = [Extra]()
            for (extraIDRaw, extraDataRaw) in receivedData {
                let extraData:NSDictionary = extraDataRaw as! NSDictionary
                let extraName:String = extraData["name"] as! String
                let extraID:String = extraIDRaw as! String // TODO: solve the conversion problem here
                
                let newExtra:Extra = Extra(name: extraName, id: Int(extraID)!)
                print(Int(extraID)!)
                resultExtras.append(newExtra)
            }
            self.notificationCenter.post(
                name: Notification.Name(rawValue:"sendExtras"),
                object: nil,
                userInfo: ["extras":resultExtras]
            )
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}
