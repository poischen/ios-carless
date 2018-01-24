//
//  HomePageViewController.swift
//  ios
//
//  Created by Konrad Fischer on 14.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let userUID = StorageAPI.shared.userID()
    
    let USER_RENTINGS_TABLE_CELL_IDENTIFIER = "userRentingsCell"
    let USER_OFFERINGS_TABLE_CELL_IDENTIFIER = "usersOfferingsCell"
    let USER_REQUESTS_TABLE_CELL_IDENTIFIER = "userRentingRequestsCell"

    @IBOutlet weak var usersRentingsTable: UITableView!
    @IBOutlet weak var usersOfferingsTable: UITableView!
    @IBOutlet weak var usersRentingsRequestsTable: UITableView!
    

    @IBOutlet weak var usersRentingsPlaceholderLabel: UILabel!
    @IBOutlet weak var userOfferingsPlaceholderLabel: UILabel!
    @IBOutlet weak var userRentingRequestsPlaceholderLabel: UILabel!
    
    var rentingEvents: [RentingEvent] = []
    var usersOfferingsAndBrands: [(Offering,Brand)] = []
    private var usersRentingRequestsMap: [String:[SomebodyRented]] = [:]
    // TODO: move into model?
    var usersRentingRequests: [SomebodyRented] {
        var result:[SomebodyRented] = []
        for (_, requestData) in usersRentingRequestsMap {
            result += requestData
        }
        return result
    }
    var volume: Double {
        return 5.0
    }
    let homePageModel = HomePageModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersRentingsTable.dataSource = self
        usersRentingsTable.delegate = self
        usersOfferingsTable.dataSource = self
        usersOfferingsTable.delegate = self
        usersRentingsRequestsTable.dataSource = self
        usersRentingsRequestsTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /* homePageModel.subscribeToUsersRentings(UID: userUID, completion: {rentingsAndOfferings in
            self.usersRentingsAndAdditionalInfo = rentingsAndOfferings
            if (rentingsAndOfferings.count == 0){
                // no rentings -> hide table and show placeholder
                self.usersRentingsTable.isHidden = true
                self.usersRentingsPlaceholderLabel.isHidden = false
            } else {
                // rentings exist -> hide placeholder and show table
                self.usersRentingsTable.reloadData()
                self.usersRentingsTable.isHidden = false
                self.usersRentingsPlaceholderLabel.isHidden = true
            }
        }) */
        
        homePageModel.subscribeToRentingEvents(UID: userUID, completion: {rentingEvents in
            self.rentingEvents = rentingEvents
            if (self.rentingEvents.count == 0){
                // no events -> hide table and show placeholder
                self.usersRentingsTable.isHidden = true
                self.usersRentingsPlaceholderLabel.isHidden = false
            } else {
                // events exist -> hide placeholder and show table
                self.usersRentingsTable.reloadData()
                self.usersRentingsTable.isHidden = false
                self.usersRentingsPlaceholderLabel.isHidden = true
            }
        })
        homePageModel.subscribeToUsersOfferings(UID: userUID, completion: {offeringsAndBrands in
            self.usersOfferingsAndBrands = offeringsAndBrands
            self.usersOfferingsTable.reloadData()
            if (offeringsAndBrands.count == 0){
                // no offerings -> hide table and show placeholder
                self.usersOfferingsTable.isHidden = true
                self.userOfferingsPlaceholderLabel.isHidden = false
            } else {
                // offering exist -> hide placeholder and show table
                self.usersOfferingsTable.reloadData()
                self.usersOfferingsTable.isHidden = false
                self.userOfferingsPlaceholderLabel.isHidden = true
            }
        })
        homePageModel.subscribeToUnconfirmedRequestsForUsersOfferings(UID: userUID, completion: {offeringID, rentingData in
            // operations here will also change the computed property usersRentingRequests which is the data source of the table
            if rentingData.count > 0 {
                // overwrite (maybe) existing requests for this offering in the map
                self.usersRentingRequestsMap[offeringID] = rentingData
            } else {
                // remove key from map if no requests for the offering exist
                self.usersRentingRequestsMap.removeValue(forKey: offeringID)
            }
            if (self.usersRentingRequestsMap.count == 0) {
                // no requests -> hide table and show placeholder
                self.usersRentingsRequestsTable.isHidden = true
                self.userRentingRequestsPlaceholderLabel.isHidden = false
            } else {
                // requests exist -> update table, show it and hide the placeholder
                self.usersRentingsRequestsTable.reloadData()
                self.usersRentingsRequestsTable.isHidden = false
                self.userRentingRequestsPlaceholderLabel.isHidden = true
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int
        
        switch tableView {
        case self.usersRentingsTable:
            count = rentingEvents.count
        case self.usersOfferingsTable:
            count = usersOfferingsAndBrands.count
        case self.usersRentingsRequestsTable:
            count = usersRentingRequests.count
        default:
            count = 0
            print("non-intended use of HomePageViewController as delegate for an unknown table view (in numberOfRowsInSection)")
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnCell:UITableViewCell = UITableViewCell()
        
        // TODO: better error handling here
        // TODO: move initialisation into cells 
        
        switch tableView {
        case self.usersRentingsTable:
            /* let (renting, offering, brand, rateable) = youRentedOrSomebodyRented[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: USER_RENTINGS_TABLE_CELL_IDENTIFIER, for: indexPath) as! YouRentedTableViewCell
            cell.carNameLabel.text = brand.name + " " + offering.type
            cell.startDateLabel.text = homePageModel.dateToString(date: renting.startDate)
            cell.endDateLabel.text = homePageModel.dateToString(date: renting.startDate)
            if (renting.confirmationStatus) {
                // renting is confirmed
                cell.statusLabel.text = YouRentedTableViewCell.ACCEPTED_STATUS_MESSAGE
            } else {
                cell.statusLabel.text = YouRentedTableViewCell.PENDING_STATUS_MESSAGE
            }
            if (rateable) {
                // renting is rateable -> show rating button
                cell.rateButton.isHidden = false
            } else {
                cell.rateButton.isHidden = true
            }
            cell.delegate = self
            cell.showedRenting = renting
            returnCell = cell*/
            let event = self.rentingEvents[indexPath.row]
            switch event.type {
            case .somebodyRented:
                if let cell = tableView.dequeueReusableCell(withIdentifier: SomebodyRentedTableViewCell.identifier, for: indexPath) as? SomebodyRentedTableViewCell {
                    cell.event = event
                    cell.delegate = self
                    returnCell = cell
                }
            case .youRented:
                if let cell = tableView.dequeueReusableCell(withIdentifier: YouRentedTableViewCell.identifier, for: indexPath) as? YouRentedTableViewCell {
                    cell.event = event
                    cell.delegate = self
                    returnCell = cell
                }
            }
        case self.usersOfferingsTable:
            let (offering, brand) = usersOfferingsAndBrands[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: USER_OFFERINGS_TABLE_CELL_IDENTIFIER, for: indexPath)
            cell.textLabel?.text = brand.name + " " + offering.type
            returnCell = cell
        case self.usersRentingsRequestsTable:
            let somebodyRented = usersRentingRequests[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: USER_REQUESTS_TABLE_CELL_IDENTIFIER, for: indexPath) as! UserRentingRequestsTableViewCell
            cell.usernameButton.setTitle(somebodyRented.userThatRented.name, for: .normal)
            cell.ratingScoreLabel.text = String(somebodyRented.userThatRented.rating)
            cell.carNameLabel.text = somebodyRented.brand.name + " " + somebodyRented.offering.type
            cell.numberOfRatingsLabel.text = "(\(somebodyRented.userThatRented.numberOfRatings) ratings)"
            // setting data necessary for using the buttons in the cell as gateway to other views
            cell.showedRenting = somebodyRented.renting
            cell.rentingUser = somebodyRented.userThatRented
            cell.delegate = self
            returnCell = cell
        default:
            returnCell = UITableViewCell()
            print("non-intended use of HomePageViewController as delegate for an unknown table view (in cellForRowAt)")
            // TODO: better way to provide an exhaustive switch here?
        }
        

        returnCell.selectionStyle = UITableViewCellSelectionStyle.none // remove blue background selection style
        return returnCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.usersOfferingsTable) {
            let (selectedOffering,_) = self.usersOfferingsAndBrands[indexPath.row]
            showSelectedOffering(selectedOffering: selectedOffering)
        } else if (tableView == self.usersRentingsTable) {
            let event = self.rentingEvents[indexPath.row]
            switch event.type {
            case .somebodyRented:
                if let somebodyRented = event as? SomebodyRented {
                    // TODO: avoid code duplication?
                    showSelectedOffering(selectedOffering: somebodyRented.offering)
                }
            case .youRented:
                if let youRented = event as? YouRented {
                    showSelectedOffering(selectedOffering: youRented.offering)
                }
            }
        }

    }

    @IBAction func addOfferingButtonClicked(_ sender: Any) {
        // go to advertise view
        let storyboard = UIStoryboard(name: "Advertise", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AdvertisePages")
        self.present(vc, animated: true, completion: nil)
    }
    
  /*  @IBAction func ratingTestButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Rate", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Rate")
        self.present(vc, animated: true, completion: nil)
    }*/
    
    func showSelectedOffering(selectedOffering: Offering){
        // show selected offering
        let storyboard = UIStoryboard(name: "Offering", bundle: nil)
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "OfferingNavigation") as? UINavigationController,
            let targetController = navigationController.topViewController as? OfferingViewController else {
                return
        }
        targetController.displayingOffering = selectedOffering
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // needed by both RequestProcessingProtocol and RatingProtocol
    func goToProfile(user: User) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        guard let profileController = storyboard.instantiateViewController(withIdentifier: "ExternProfile") as? ExternProfileViewController else {
            return
        }
        profileController.profileOwner = user
        self.present(profileController, animated: true, completion: nil)
    }

}

extension HomePageViewController: RequestProcessingProtocol{
    
    func acceptRequest(renting: Renting) {
        homePageModel.acceptRenting(renting: renting)
        //removeRequestFromList(renting: renting)
    }
    
    func denyRequest(renting: Renting) {
        homePageModel.denyRenting(renting: renting)
        //removeRequestFromList(renting: renting)
    }
}

extension HomePageViewController: RatingProtocol{
    // TODO: avoid code duplication here?
    
    func rateLessee(renting: Renting, lesseeUser: User) {
        let storyboard = UIStoryboard(name: "Rate", bundle: nil)
        guard let rateController = storyboard.instantiateViewController(withIdentifier: "Rate") as? RateViewController else {
                return
        }
        rateController.rentingBeingRated = renting
        rateController.lesseeUser = lesseeUser
        self.present(rateController, animated: true, completion: nil)
    }
    func rateLessor(renting: Renting) {
        let storyboard = UIStoryboard(name: "Rate", bundle: nil)
        guard let rateController = storyboard.instantiateViewController(withIdentifier: "Rate") as? RateViewController else {
            return
        }
        rateController.rentingBeingRated = renting
        rateController.rateLessee = false
        self.present(rateController, animated: true, completion: nil)
    }
    
    
}
