//
//  SearchResultViewController.swift
//  ios
//
//  Created by Konrad Fischer on 24.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit
import Kingfisher

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var offerings:[Offering]?
    var searchFilter:Filter?
    let searchModel:SearchModel = SearchModel.shared
    
    var preselectedStartDate: Date?
    var preselectedEndDate: Date?
    
    var cameFromOffering = false
    
    @IBOutlet weak var searchResultsTable: UITableView!
    
    let SEARCH_OFFER_SEGUE = "SearchOfferSegue"
    let SEARCH_BUTTON_OFFER_SEGUE = "SearchButtonOfferSegue"
    let FILTER_SEGUE = "showFilter"
    let SEARCH_RESULTS_CELL_IDENTIFIER = "SearchResultsCell"
    
    let storageAPI = StorageAPI.shared
    
    // error messages for the alert
    let ERROR_ALERT_TITLE = "Sorry"
    let NO_OFFERINGS_FOUND_ERROR = "We couln't find a car for you. :("
    let ERROR_BACK_BUTTON_TEXT = "back to search"
    
    // text pieces for labels
    let SEATS_LABEL_END_TEXT = " seats"
    let MILEAGE_LABEL_END_TEXT = "l/100km"
    let PRICE_LABEL_END_TEXT = "€ per day"
    let PRICE_LABEL_START_TEXT = "max. "
    
    let LOADING_PLACEHOLDER_TEXT = "loading"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set this view controller as the data source and delegate of the table view
        searchResultsTable.delegate = self
        searchResultsTable.dataSource = self
        
        searchResultsTable.backgroundColor = UIColor.clear
        searchResultsTable.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // only search (again) if the last screen was not the offering
        if (!cameFromOffering) {
            // empty offerings to prevent showing an offering that doesn't fit the search filter in the background of the "no cars found" popup
            // offerings will be filled again if the search is successfull
            if let currentOfferings = offerings, currentOfferings.count > 0{
                self.offerings = []
                self.searchResultsTable.reloadData()
            }
            // last screen that was shown is the filter -> get new offerings to apply filter
            self.searchModel.getFilteredOfferings(filter: self.searchFilter!, completion: self.receiveOfferings)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentOfferings = offerings {
            return currentOfferings.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: SEARCH_RESULTS_CELL_IDENTIFIER, for: indexPath) as? SearchResultsTableViewCell, let currentOfferings = offerings {
            // get offering to be displayed
            let offering = currentOfferings[indexPath.row]
            cell.offering = offering
            cell.parent = self
            
            cell.modelLabel.text = LOADING_PLACEHOLDER_TEXT
            // get the offering's brand and set the model label to the right name after receiving it
            self.storageAPI.getBrandByID(id: offering.brandID, completion: {brand in
                let icon = UIImage(named: brand.name)
                cell.brandIcon.image = icon
                cell.modelLabel.text = offering.type
            })
            
            // get the offering's gear and set the gear label to the right name after receiving it
            self.storageAPI.getGearByID(id: offering.gearID, completion: {gear in
                let icon = UIImage(named: gear.name)
                if (icon == nil) {
                    let iconURL = URL(string: gear.iconURL)
                    cell.gearIcon.kf.setImage(with: iconURL)
                } else {
                    cell.gearIcon.image = icon
                }
            })
            
            // get the offering's fuel and set the fuel label to the right name after receiving it
            self.storageAPI.getFuelByID(id: offering.fuelID, completion: {fuel in
                let icon = UIImage(named: fuel.name)
                if (icon == nil) {
                    let iconURL = URL(string: fuel.iconURL)
                    cell.fuelIcon.kf.setImage(with: iconURL)
                } else {
                    cell.fuelIcon.image = icon
                }
            })
            
            // set remaining labels that can be set with values from the offering itself
            let iconName = String(offering.seats)
            let icon = UIImage(named: iconName)
            cell.seatsIcon.image = icon
            
            cell.mileageLabel.text = String(offering.consumption) + MILEAGE_LABEL_END_TEXT
            cell.locationLabel.text = offering.location
            let price: String = PRICE_LABEL_START_TEXT + String(offering.basePrice) + PRICE_LABEL_END_TEXT
            cell.priceButton.setTitle(price, for: .normal)
            
            // get offering's picture from it's pricture url
            /*let url = URL(string: offering.pictureURL)
            let data = try? Data(contentsOf: url!)
            if let currentData = data, let currentImage = UIImage(data: currentData) {
                cell.photo.image = currentImage
            } else {
                print("error while getting an offerings image in cellForRowAt")
            }*/
            
            let carImageUrl = URL(string: offering.pictureURL)
            cell.photo.kf.setImage(with: carImageUrl)
            
            cell.selectionStyle = .none
            cell.contentView.backgroundColor = UIColor.clear
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func receiveOfferings(_ offerings: [Offering]) {
        if (offerings.count <= 0) {
            // show error message if no offerings were received (because the search returned no results)
            let alertController = UIAlertController(title: ERROR_ALERT_TITLE, message: NO_OFFERINGS_FOUND_ERROR, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: ERROR_BACK_BUTTON_TEXT, style: .cancel, handler: {alterAction in
                self.navigationController?.popViewController(animated: true)
            })
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        } else {
            // offerings received -> save offerings, reload table to show them
            self.offerings = offerings
            self.searchResultsTable.reloadData()
        }
    }

    func goToOffering(offer: Offering) {
        let storyboard = UIStoryboard(name: "Offering", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OfferingNavigation") as! UINavigationController
        let offeringController = vc.topViewController as? OfferingViewController
    
        // pass selected dates to offering view
        if let psd = preselectedStartDate, let ped = preselectedEndDate, let offeringVC = offeringController {
            offeringVC.preselectedStartDate = psd
            offeringVC.preselectedEndDate = ped
            offeringVC.displayingOffering = offer
        }

    
        // remember that the offering controller is shown
        cameFromOffering = true
    
        self.present(vc, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == SEARCH_OFFER_SEGUE) {
            guard
                let offeringNavigationController = segue.destination as? UINavigationController,
                let offeringController = offeringNavigationController.topViewController as? OfferingViewController,
                let indexPath = searchResultsTable.indexPathForSelectedRow,
                let currentOfferings = offerings else {
                    return
            }
            
            let index = indexPath.row
            let selectedOffering = currentOfferings[index]
            // pass selected dates to offering view
            if let psd = preselectedStartDate, let ped = preselectedEndDate {
                offeringController.preselectedStartDate = psd
                offeringController.preselectedEndDate = ped
            }
            offeringController.displayingOffering = selectedOffering
            
            // remember that the offering controller is shown
            cameFromOffering = true
        } else if (segue.identifier == FILTER_SEGUE) {
            // next screen: filter
            if let filterViewController = segue.destination as? FilterViewController {
                // set filter screen's default values here
                if let currentSearchFilter = searchFilter {
                    // only set the values if they're not set yet -> if this is the first time the filter view is opened
                    if currentSearchFilter.maxPrice == nil {
                        currentSearchFilter.maxPrice = 100 // default value for maxPrice
                    }
                    if currentSearchFilter.maxConsumption == nil {
                        currentSearchFilter.maxConsumption = 10 // default value for maxConsumption
                    }
                    if currentSearchFilter.minHP == nil {
                        currentSearchFilter.minHP = 50 // default value for minHp
                    }
                }
                
                // pass current filter to the filter screen to be able to modify it there
                filterViewController.searchFilter = self.searchFilter
                
                // remember that the filter controller is shown
                cameFromOffering = false
            }
        }
        
    }
}
