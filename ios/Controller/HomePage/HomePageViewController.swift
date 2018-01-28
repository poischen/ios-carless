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
    let RATING_NAVIGATION_IDENTIFIER = "RatingNav"
    let RATE_STORYBOARD_IDENTIFIER = "Rate"
    
    @IBOutlet weak var usersRentingsTable: UITableView!
    @IBOutlet weak var usersOfferingsTable: UITableView!
    @IBOutlet weak var usersRentingsRequestsTable: UITableView!
    @IBOutlet weak var usersRentingsPlaceholderLabel: UILabel!
    @IBOutlet weak var userOfferingsPlaceholderLabel: UILabel!
    @IBOutlet weak var userRentingRequestsPlaceholderLabel: UILabel!
    
    var rentingEvents: [RentingEvent]?
    var usersOfferingsAndBrands: [(Offering,Brand)]?
    var usersRentingRequests: [SomebodyRented]? // TODO: use optional here
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
        if let uid = userUID {
            homePageModel.subscribeToRentingEvents(UID: uid, completion: {rentingEvents in
                self.rentingEvents = rentingEvents
                if (rentingEvents.count == 0){
                    // no events -> hide table and show placeholder
                    self.usersRentingsTable.isHidden = true
                    self.usersRentingsPlaceholderLabel.isHidden = false
                } else {
                    // events exist -> hide placeholder and show table
                    self.usersRentingsTable.reloadData() // TODO: necessary?
                    self.usersRentingsTable.isHidden = false
                    self.usersRentingsPlaceholderLabel.isHidden = true
                }
            })
            homePageModel.subscribeToUsersOfferings(UID: uid, completion: {offeringsAndBrands in
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
            homePageModel.subscribeToUnconfirmedRequestsForUsersOfferings(UID: uid, completion: {rentingData in
                self.usersRentingRequests = rentingData
                if (rentingData.count == 0) {
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // set default count that is overwritten is one of the cases matches
        var count = 0
        
        switch tableView {
        case self.usersRentingsTable:
            if let currentRentingEvents = rentingEvents {
                count = currentRentingEvents.count
            }
        case self.usersOfferingsTable:
            if let currentUsersOfferings = usersOfferingsAndBrands {
                count = currentUsersOfferings.count
            }
        case self.usersRentingsRequestsTable:
            if let currentUsersRentingRequests = usersRentingRequests {
                count = currentUsersRentingRequests.count
            }
        default:
            print("non-intended use of HomePageViewController as delegate for an unknown table view (in numberOfRowsInSection)")
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // set default cell that is overwritten is one of the cases matches
        var returnCell:UITableViewCell = UITableViewCell()
        
        switch tableView {
        case self.usersRentingsTable:
            if let currentRentingEvents = rentingEvents {
                let event = currentRentingEvents[indexPath.row]
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
            }
        case self.usersOfferingsTable:
            if let currentUsersOfferings = usersOfferingsAndBrands {
                // initialisation of this cell is in this class as no special cell class is used here
                let (offering, brand) = currentUsersOfferings[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: USER_OFFERINGS_TABLE_CELL_IDENTIFIER, for: indexPath)
                cell.textLabel?.text = brand.name + " " + offering.type
                returnCell = cell
            }
        case self.usersRentingsRequestsTable:
            if let currentUsersRentingRequests = usersRentingRequests {
                let somebodyRented = currentUsersRentingRequests[indexPath.row]
                if let cell = tableView.dequeueReusableCell(withIdentifier: USER_REQUESTS_TABLE_CELL_IDENTIFIER, for: indexPath) as? UserRentingRequestsTableViewCell {
                    cell.somebodyRented = somebodyRented
                    cell.delegate = self
                    returnCell = cell
                }
            }
        default:
            print("non-intended use of HomePageViewController as delegate for an unknown table view (in cellForRowAt)")
        }
        
        
        returnCell.selectionStyle = UITableViewCellSelectionStyle.none // remove blue background selection style
        return returnCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.usersOfferingsTable) {
            if let currentUsersOfferingsAndBrands = usersOfferingsAndBrands {
                let (selectedOffering,_) = currentUsersOfferingsAndBrands[indexPath.row]
                showSelectedOffering(selectedOffering: selectedOffering)
            }
        } else if (tableView == self.usersRentingsTable) {
            if let currentRentingEvents = rentingEvents {
                let event = currentRentingEvents[indexPath.row]
                switch event.type {
                case .somebodyRented:
                    if let somebodyRented = event as? SomebodyRented {
                        showSelectedOffering(selectedOffering: somebodyRented.offering)
                    }
                case .youRented:
                    if let youRented = event as? YouRented {
                        showSelectedOffering(selectedOffering: youRented.offering)
                    }
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
        let storyboard = UIStoryboard(name: ProfileViewController.PROFILE_STORYBOARD_IDENTIFIER, bundle: nil)
        guard let navProfileController = storyboard.instantiateViewController(withIdentifier: ProfileViewController.PROFILE_NAVIGATION_IDENTIFIER) as? UINavigationController,
              let profileController = navProfileController.topViewController as? ProfileViewController else {
            return
        }
        profileController.profileOwner = user
        profileController.cancelButtonNeeded = true
        self.present(navProfileController, animated: true, completion: nil)
    }
    
}

extension HomePageViewController: RequestProcessingProtocol{
    
    func acceptRequest(renting: Renting) {
        homePageModel.acceptRenting(renting: renting)
    }
    
    func denyRequest(renting: Renting) {
        homePageModel.denyRenting(renting: renting)
    }
    
}

extension HomePageViewController: RatingProtocol{
    func rateLessee(renting: Renting, lesseeUser: User) {
        let (navController, rateController) = goToRenting()
        rateController.rentingBeingRated = renting
        rateController.userBeingRated = lesseeUser
        self.present(navController, animated: true, completion: nil)
    }
    func rateLessor(renting: Renting) {
        let (navController, rateController) = goToRenting()
        rateController.rentingBeingRated = renting
        rateController.ratingLessee = false
        self.present(navController, animated: true, completion: nil)
    }
    
    func goToRenting() -> (UINavigationController, RateViewController) {
        let storyboard = UIStoryboard(name: RATE_STORYBOARD_IDENTIFIER, bundle: nil)
        let rateNavController = storyboard.instantiateViewController(withIdentifier: RATING_NAVIGATION_IDENTIFIER) as! UINavigationController
        let rateController = rateNavController.topViewController as! RateViewController
        return (rateNavController, rateController)
    }
    
}

