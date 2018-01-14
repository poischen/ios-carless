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
    @IBOutlet weak var usersRentingRequestsTable: UITableView!
    
    var usersRentingsAndOfferings: [(Renting, Offering, Brand)] = []
    var usersOfferingsAndBrands: [(Offering,Brand)] = []
    var usersRentingRequests: [(Offering, Brand, User, Renting)] = []
    let homePageModel = HomePageModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersRentingsTable.dataSource = self
        usersRentingsTable.delegate = self
        usersOfferingsTable.dataSource = self
        usersOfferingsTable.delegate = self
        usersRentingRequestsTable.dataSource = self
        usersRentingRequestsTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homePageModel.getUsersRentings(UID: userUID, completion: {rentingsAndOfferings in
            self.usersRentingsAndOfferings = rentingsAndOfferings
            self.usersRentingsTable.reloadData()
        })
        homePageModel.getUsersOfferings(UID: userUID, completion: {offeringsAndBrands in
            self.usersOfferingsAndBrands = offeringsAndBrands
            self.usersOfferingsTable.reloadData()
        })
        homePageModel.getUnconfirmedOfferingsForUsersOfferings(UID: userUID, completion: {offeringsBrandsAndUsers in
            self.usersRentingRequests = offeringsBrandsAndUsers
            self.usersRentingRequestsTable.reloadData()
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
        case self.usersRentingRequestsTable:
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
            returnCell = cell
        case self.usersOfferingsTable:
            let (offering, brand) = usersOfferingsAndBrands[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: USER_OFFERINGS_TABLE_CELL_IDENTIFIER, for: indexPath)
            cell.textLabel?.text = brand.name + " " + offering.type
            returnCell = cell
        case self.usersRentingRequestsTable:
            let (offering, brand, user, renting) = usersRentingRequests[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: USER_REQUESTS_TABLE_CELL_IDENTIFIER, for: indexPath) as! UserRentingRequestsTableViewCell
            cell.usernameLabel.text = user.name
            cell.ratingScoreLabel.text = String(user.rating)
            cell.carNameLabel.text = brand.name + " " + offering.type
            cell.numberOfRatingsLabel.text = "(\(user.numberOfRatings) ratings)"
            returnCell = cell
        default:
            returnCell = UITableViewCell()
            print("non-intended use of HomePageViewController as delegate for an unknown table view (in cellForRowAt)")
            // TODO: better way to provide an exhaustive switch here?
            //cellIdentifier = USER_REQUESTS_TABLE_CELL_IDENTIFIER
            //cellContent = vehicleTypes[indexPath.row]
        }
        

        returnCell.selectionStyle = UITableViewCellSelectionStyle.none // remove blue background selection style
        return returnCell
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
