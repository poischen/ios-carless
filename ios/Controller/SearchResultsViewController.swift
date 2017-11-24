//
//  SearchResultViewController.swift
//  ios
//
//  Created by Konrad Fischer on 24.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var offerings:[Offering] = []
    var searchFilter:Filter?
    @IBOutlet weak var searchResultsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsTable.delegate = self
        searchResultsTable.dataSource = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offerings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchResultsCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SearchResultsTableViewCell else {
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
    
    func receiveOfferings(_ offerings: [Offering]) {
        print("called new receiveOfferings")
        self.offerings = offerings
        self.searchResultsTable.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
