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
    
    init() {
        self.notificationCenter = NotificationCenter.default
    }
    
    func filterOfferings(filter: Filter) {
        print("hallo")
        // TODO: Query DB in the right way
        let url = URL(string: "https://us-central1-ioscars-32e69.cloudfunctions.net/filteredOfferings?minSeats=1")

        URLSession.shared.dataTask(with: url!) { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            guard let data = data else {
                print("Data is empty")
                return
            }
            
            print(data)
            let json = try! JSONSerialization.jsonObject(with: data, options: [])
            print(json)
        }
    }
}
