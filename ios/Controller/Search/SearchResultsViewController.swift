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
    
    let dbMapping = DBMapping.shared
    let storageAPI = StorageAPI.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchResultsTable.delegate = self
        searchResultsTable.dataSource = self

        /* self.dbMapping.fillBrandsCache(completion: {
            self.searchResultsTable.reloadData()
        }) */
        /*self.dbMapping.fillGearsCache(completion: {
            self.searchResultsTable.reloadData()
        }) */
        /* self.dbMapping.fillFuelsCache(completion: {
            self.searchResultsTable.reloadData()
        }) */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // empty offerings to prevent showing an offering that doesn't fit the search filter in the background of the "no cars found" popup
        // offerings will be filled again if the search is successfull
        if (self.offerings.count > 0){
            self.offerings = []
            self.searchResultsTable.reloadData()
        }
        
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
            fatalError("The dequeued cell is not an instance of SearchResultsTableViewCell.")
        }
        
        let offering = offerings[indexPath.row]
        
        /* if let offeringsBrand = self.dbMapping.mapBrandIDToBrand(id: offering.brandID) {
            print("setting brand")
            cell.modelLabel.text = offeringsBrand.name + " " + offering.type
        } else {
            cell.modelLabel.text = "loading"
        } */
        cell.modelLabel.text = "loading"
        self.storageAPI.getBrandByID(id: offering.brandID, completion: {brand in
            cell.modelLabel.text = brand.name + " " + offering.type
        })
        
        /* if let offeringsGear = self.dbMapping.mapGearIDToGear(id: offering.gearID) {
            cell.gearshiftLabel.text = offeringsGear.name
        } else {
            cell.gearshiftLabel.text = "loading"
        } */
        
        cell.gearshiftLabel.text = "loading"
        self.storageAPI.getGearByID(id: offering.gearID, completion: {gear in
            cell.gearshiftLabel.text = gear.name
        })
        
        /* if let offeringsFuel = self.dbMapping.mapFuelIDToFuel(id: offering.fuelID) {
            cell.fuelLabel.text = offeringsFuel.name
        } else {
            cell.fuelLabel.text = "loading"
        } */
        
        cell.fuelLabel.text = "loading"
        self.storageAPI.getFuelByID(id: offering.fuelID, completion: {fuel in
            cell.fuelLabel.text = fuel.name
        })
        
        cell.seatsLabel.text = String(offering.seats) + " seats"
        cell.mileageLabel.text = String(offering.consumption) + "l/100km"
        cell.locationLabel.text = offering.location
        cell.priceLabel.text = "from " + String(offering.basePrice) + "€ per day"
        let url = URL(string: offering.pictureURL)
        let data = try? Data(contentsOf: url!)
        let image: UIImage = UIImage(data: data!)! // TODO: better error handling here
        cell.photo.image = image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOffering = self.offerings[indexPath.row]
        let storyboard = UIStoryboard(name: "Offering", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "Offering") as? OfferingViewController{
            viewController.displayingOffering = selectedOffering
            self.present(viewController, animated: true, completion: nil)
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showFilter") {
            // next screen: filter
            if let filterViewController = segue.destination as? FilterViewController {
                // set filter screen's default values here
                if self.searchFilter != nil {
                    // only set the values if they're not set yet -> if this is the first time the filter view is opened
                    if self.searchFilter!.maxPrice == nil {
                        self.searchFilter!.maxPrice = 100
                    }
                    if self.searchFilter!.maxConsumption == nil {
                        self.searchFilter!.maxConsumption = 10
                    }
                    if self.searchFilter!.minHP == nil {
                        self.searchFilter!.minHP = 50
                    }
                }
                
                // pass current filter to the filter screen to be able to modify it there
                filterViewController.searchFilter = self.searchFilter
            }
        }
    }
}
