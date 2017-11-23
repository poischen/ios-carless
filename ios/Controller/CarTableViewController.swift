//
//  CarTableViewController.swift
//  iOS Cars
//
//  Created by Konrad Fischer on 03.11.17.
//  Copyright © 2017 Konrad Fischer. All rights reserved.
//

import UIKit

class CarTableViewController: UITableViewController {
    
    var offerings = [Offering]()
    let notificationCenter: NotificationCenter = NotificationCenter.default
    let storageAPI: StorageAPI = StorageAPI.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCenter.addObserver(
            forName:Notification.Name(rawValue:"sendOfferings"),
            object:nil,
            queue:nil,
            using:receiveOfferings
        )
        /* notificationCenter.addObserver(
            forName:Notification.Name(rawValue:"sendFilteredCars"),
            object:nil,
            queue:nil,
            using:receiveOfferings
        ) */
        storageAPI.getOfferings()
        //loadSampleCars()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offerings.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CarTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CarTableViewCell else {
            fatalError("The dequeued cell is not an instance of CarTableViewCell.")
        }

        let offering = offerings[indexPath.row]
        
        cell.fuelLabel.text = offering.fuel
        cell.modelLabel.text = offering.brand + " " + offering.type
        cell.seatsLabel.text = String(offering.seats) + " seats"
        cell.gearshiftLabel.text = offering.gear
        cell.mileageLabel.text = String(offering.consumption) + "l/100km"
        //cell.locationLabel.text = offering.location
        // TODO: make location and price dynamic
        cell.locationLabel.text = offering.location
        cell.priceLabel.text = "10€ per day"
        print(offering.pictureURL)
        let url = URL(string: offering.pictureURL)
        let data = try? Data(contentsOf: url!)
        let image: UIImage = UIImage(data: data!)!
        cell.photo.image = image
    
        return cell
    }
    
    func receiveOfferings(notification: Notification) -> Void {
        print("received cars")
        guard let userInfo = notification.userInfo,
            let receivedCars  = userInfo["offerings"] as? [Offering] else {
                print("No userInfo found in notification")
                return
        }
        print("I received " + String(receivedCars.count) + " cars")
        offerings = receivedCars
        self.tableView.reloadData()
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    /* private func loadSampleCars() {
        
        print("yay")
        
        //     init?(model: Int, gearshift: Int, mileage: Double, fuel: Double, seats: Int, extras: [String], location: String, photo: UIImage?, rating: Int) {
        let photo = UIImage(named: "car1")
        let car1 = Car(model: 42, gearshift: 0, mileage: 5.0, fuel: 1, seats: 5, extras: ["Kindersitz"], location: "München, Schwabing", photo: photo, rating: 5, price: 42)
        let car2 = Car(model: 45, gearshift: 0, mileage: 5.0, fuel: 1, seats: 7, extras: ["Kindersitz", "Navi"], location: "München, Schwabing", photo: photo, rating: 5, price: 10)
        let car3 = Car(model: 45, gearshift: 1, mileage: 5.0, fuel: 1, seats: 7, extras: ["Kindersitz", "Navi"], location: "München, Neuhausen", photo: photo, rating: 5, price: 100)
        
        cars += [car1, car2, car3]
    }*/

}
