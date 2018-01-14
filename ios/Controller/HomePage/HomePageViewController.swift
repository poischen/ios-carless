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
    let USER_OFFERINGS_TABLE_CELL_IDENTIFIER = "userOfferingsCell"
    let USER_REQUESTS_TABLE_CELL_IDENTIFIER = "userRentingRequestsCell"

    @IBOutlet weak var usersRentingsTable: UITableView!
    @IBOutlet weak var usersOfferingsTable: UITableView!
    @IBOutlet weak var usersRentingRequestsTable: UITableView!
    
    var usersRentingsAndOfferings: [(Renting, Offering, Brand)] = []
    var userOfferings: [Offering] = []
    let homePageModel = HomePageModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usersRentingsTable.dataSource = self
        usersRentingsTable.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        homePageModel.getUsersRentings(UID: userUID, completion: {rentingsAndOfferings in
            self.usersRentingsAndOfferings = rentingsAndOfferings
            self.usersRentingsTable.reloadData()
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
            count = userOfferings.count
        case self.usersRentingRequestsTable:
            // TODO: change
            count = 0
        default:
            count = 0
            print("non-intended use of FilterViewController as delegate for an unknown table view (in numberOfRowsInSection)")
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var returnCell:UITableViewCell
        
        switch tableView {
        case self.usersRentingsTable:
            let (renting, offering, brand) = usersRentingsAndOfferings[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: USER_RENTINGS_TABLE_CELL_IDENTIFIER, for: indexPath) as! UserRentingsTableViewCell
            cell.carNameLabel.text = brand.name + " " + offering.type
            cell.startDateLabel.text = homePageModel.dateToString(date: renting.startDate)
            cell.endDateLabel.text = homePageModel.dateToString(date: renting.startDate)
            returnCell = cell
        case self.usersOfferingsTable:
            returnCell = UITableViewCell()
            //cellIdentifier = USER_OFFERINGS_TABLE_CELL_IDENTIFIER
        default: // covers usersRentingRequestsTable
            returnCell = UITableViewCell()
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
