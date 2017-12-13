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
    let searchModel:SearchModel = SearchModel()
    @IBOutlet weak var searchResultsTable: UITableView!
    
    var fuels:[Fuel] = [Fuel]()
    var brands:[Brand]?
    var gears:[Gear] = [Gear]()
    
    let storageAPI = StorageAPI.shared
    let dbMapping = DBMapping.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsTable.delegate = self
        searchResultsTable.dataSource = self

        self.dbMapping.fillBrandsCache(completion: {
            self.searchResultsTable.reloadData()
        })
        self.dbMapping.fillGearsCache(completion: {
            self.searchResultsTable.reloadData()
        })
        self.dbMapping.fillFuelsCache(completion: {
            self.searchResultsTable.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.searchModel.getFilteredOfferings(filter: self.searchFilter!, completion: self.receiveOfferings)
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
        
        //cell.modelLabel.text = offering.type
        
        if let offeringsBrand = self.dbMapping.mapBrandIDToBrand(id: offering.brandID) {
            cell.modelLabel.text = offeringsBrand.name + " " + offering.type
        } else {
            cell.modelLabel.text = "loading"
        }
        
        if let offeringsGear = self.dbMapping.mapGearIDToGear(id: offering.gearID) {
            cell.gearshiftLabel.text = offeringsGear.name
        } else {
            cell.gearshiftLabel.text = "loading"
        }
        
        if let offeringsFuel = self.dbMapping.mapFuelIDToFuel(id: offering.fuelID) {
            cell.fuelLabel.text = offeringsFuel.name
        } else {
            cell.fuelLabel.text = "loading"
        }
        
        //         cell.modelLabel.text = String(offering.brandID) + " " + offering.type

        cell.seatsLabel.text = String(offering.seats) + " seats"
        cell.mileageLabel.text = String(offering.consumption) + "l/100km"
        // cell.locationLabel.text = offering.location
        // TODO: make location and price dynamic
        cell.locationLabel.text = offering.location
        cell.priceLabel.text = "from " + String(offering.basePrice) + "€ per day"
        let url = URL(string: offering.pictureURL)
        let data = try? Data(contentsOf: url!)
        let image: UIImage = UIImage(data: data!)!
        cell.photo.image = image
        
        return cell
    }
    
    func receiveOfferings(_ offerings: [Offering]) {
        if (offerings.count <= 0) {
            let alertController = UIAlertController(title: "Sorry", message: "We couln't find a car for you. :(", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "back to search", style: .cancel, handler: {alterAction in
                self.navigationController?.popViewController(animated: true)
            })
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.offerings = offerings
            self.searchResultsTable.reloadData()
            
        }
    }
    
    func receiveBrands(brands: [Brand]) {
        self.brands = brands
        self.searchResultsTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showFilter") {
            // next screen: filter
            if let filterViewController = segue.destination as? FilterViewController {
                // pass current filter to the filter screen to be able to modify it there
                filterViewController.searchFilter = self.searchFilter
            }
        }
    }
}
