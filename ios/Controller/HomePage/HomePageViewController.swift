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
    
    var usersRentingsAndOfferings: [(Renting, Offering, Brand)] = []
    var usersOfferingsAndBrands: [(Offering,Brand)] = []
    private var usersRentingRequestsMap: [String:[(Offering, Brand, User, Renting)]] = [:]
    var usersRentingRequests: [(Offering, Brand, User, Renting)] {
        var result:[(Offering, Brand, User, Renting)] = []
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
        homePageModel.subscribeToUsersRentings(UID: userUID, completion: {rentingsAndOfferings in
            self.usersRentingsAndOfferings = rentingsAndOfferings
            if (rentingsAndOfferings.count == 0){
                // no rentings -> hide table and show placeholder
                self.usersRentingsTable.isHidden = true
                self.usersRentingsPlaceholderLabel.isHidden = false
                self.usersRentingsTable.reloadData()
            } else {
                // rentings exist -> hide placeholder and show table
                self.usersRentingsTable.isHidden = false
                self.usersRentingsPlaceholderLabel.isHidden = true
            }
        })
        homePageModel.subscribeToUsersOfferings(UID: userUID, completion: {offeringsAndBrands in
            self.usersOfferingsAndBrands = offeringsAndBrands
            self.usersOfferingsTable.reloadData()
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
            count = usersRentingsAndOfferings.count
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
        var returnCell:UITableViewCell
        
        // TODO: better error handling here
        
        switch tableView {
        case self.usersRentingsTable:
            let (renting, offering, brand) = usersRentingsAndOfferings[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: USER_RENTINGS_TABLE_CELL_IDENTIFIER, for: indexPath) as! UserRentingsTableViewCell
            cell.carNameLabel.text = brand.name + " " + offering.type
            cell.startDateLabel.text = homePageModel.dateToString(date: renting.startDate)
            cell.endDateLabel.text = homePageModel.dateToString(date: renting.startDate)
            if (renting.confirmationStatus) {
                // renting is confirmed
                cell.statusLabel.text = UserRentingsTableViewCell.ACCEPTED_STATUS_MESSAGE
            } else {
                cell.statusLabel.text = UserRentingsTableViewCell.PENDING_STATUS_MESSAGE
            }
            returnCell = cell
        case self.usersOfferingsTable:
            let (offering, brand) = usersOfferingsAndBrands[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: USER_OFFERINGS_TABLE_CELL_IDENTIFIER, for: indexPath)
            cell.textLabel?.text = brand.name + " " + offering.type
            returnCell = cell
        case self.usersRentingsRequestsTable:
            let (offering, brand, user, renting) = usersRentingRequests[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: USER_REQUESTS_TABLE_CELL_IDENTIFIER, for: indexPath) as! UserRentingRequestsTableViewCell
            cell.usernameButton.setTitle(user.name, for: .normal)
            cell.ratingScoreLabel.text = String(user.rating)
            cell.carNameLabel.text = brand.name + " " + offering.type
            cell.numberOfRatingsLabel.text = "(\(user.numberOfRatings) ratings)"
            // setting data necessary for using the buttons in the cell as gateway to other views
            cell.showedRenting = renting
            cell.rentingUser = user
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
            let (_,selectedOffering,_) = self.usersRentingsAndOfferings[indexPath.row]
            showSelectedOffering(selectedOffering: selectedOffering)
        }

    }

    @IBAction func addOfferingButtonClicked(_ sender: Any) {
        // go to advertise view
        let storyboard = UIStoryboard(name: "Advertise", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AdvertisePages")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func ratingTestButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Rate", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Rate")
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
    

}

extension HomePageViewController: RequestProcessingProtocol{
    func goToProfile(user: User) {
        let storyboard = UIStoryboard(name: "Profile", bundle: nil)
        guard let profileController = storyboard.instantiateViewController(withIdentifier: "ExternProfile") as? ExternProfileViewController else {
                return
        }
        profileController.profileOwner = user
        self.present(profileController, animated: true, completion: nil)
    }
    
    func acceptRequest(renting: Renting) {
        homePageModel.acceptRenting(renting: renting)
        //removeRequestFromList(renting: renting)
    }
    
    func denyRequest(renting: Renting) {
        homePageModel.denyRenting(renting: renting)
        //removeRequestFromList(renting: renting)
    }
    
    
    
    func removeRequestFromList(renting: Renting) {
        if let wantedRentingID = renting.id {
            /* usersRentingRequests = usersRentingRequests.filter {(_,_,_,currentRenting) in
                if let currentRentingID = currentRenting.id  {
                    return currentRentingID != wantedRentingID
                } else {
                    return false
                }
            }*/
        }
        usersRentingsRequestsTable.reloadData()
    }
}
