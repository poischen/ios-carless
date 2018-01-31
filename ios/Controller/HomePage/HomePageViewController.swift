//
//  HomePageViewController.swift
//  ios
//
//  Created by Konrad Fischer on 14.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import ScalingCarousel

class HomePageViewController: UIViewController, UICollectionViewDelegate {
    let userUID = StorageAPI.shared.userID()
    
    let USER_RENTINGS_TABLE_CELL_IDENTIFIER = "userRentingsCell"
    let USER_OFFERINGS_TABLE_CELL_IDENTIFIER = "usersOfferingsCell"
    let USER_REQUESTS_TABLE_CELL_IDENTIFIER = "userRentingRequestsCell"
    let RATING_NAVIGATION_IDENTIFIER = "RatingNav"
    let RATE_STORYBOARD_IDENTIFIER = "Rate"
    
    @IBOutlet weak var usersRentingsTable: ScalingCarouselView!
    @IBOutlet weak var usersOfferingsTable: ScalingCarouselView!
    @IBOutlet weak var usersRentingsRequestsTable: ScalingCarouselView!
    
    @IBOutlet weak var usersRentingsPlaceholderLabel: UILabel!
    @IBOutlet weak var userOfferingsPlaceholderLabel: UILabel!
    @IBOutlet weak var userRentingRequestsPlaceholderLabel: UILabel!
    
    var rentingEvents: [RentingEvent]?
    var usersOfferingsAndBrands: [(Offering,Brand)]?
    var usersRentingRequests: [SomebodyRented]?
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
            // data for the first table on the home page
            homePageModel.subscribeToRentingEvents(UID: uid, completion: {rentingEvents in
                self.rentingEvents = rentingEvents
                if (rentingEvents.count == 0){
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
            
            // data for the second table on the home page
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
            
            // data for the third table on the home page
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView {
        case self.usersRentingsTable:
            usersRentingsTable.didScroll()
            
        case self.usersOfferingsTable:
            usersOfferingsTable.didScroll()
            
        case self.usersRentingsRequestsTable:
            usersRentingsRequestsTable.didScroll()
            
        default:
            break
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
        // pass necessary information for rating to rating view
        rateController.rentingBeingRated = renting
        rateController.userBeingRated = lesseeUser
        self.present(navController, animated: true, completion: nil)
    }
    func rateLessor(renting: Renting) {
        let (navController, rateController) = goToRenting()
        // pass necessary information for rating to rating view
        rateController.rentingBeingRated = renting
        rateController.ratingLessee = false
        self.present(navController, animated: true, completion: nil)
    }
    
    // find navigation controller and rate view controller
    func goToRenting() -> (UINavigationController, RateViewController) {
        let storyboard = UIStoryboard(name: RATE_STORYBOARD_IDENTIFIER, bundle: nil)
        let rateNavController = storyboard.instantiateViewController(withIdentifier: RATING_NAVIGATION_IDENTIFIER) as! UINavigationController
        let rateController = rateNavController.topViewController as! RateViewController
        return (rateNavController, rateController)
    }
    
    func presentOfferView(offer: Offering){
        let storyboard = UIStoryboard(name: "Offering", bundle: nil)
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "OfferingNavigation") as? UINavigationController,
            let targetController = navigationController.topViewController as? OfferingViewController else {
                return
        }
        targetController.displayingOffering = offer
        self.present(navigationController, animated: true, completion: nil)
    }
    
}

extension HomePageViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // set default count that is overwritten is one of the cases matches
        var count = 0
        switch collectionView {
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.usersRentingsTable:
            if let currentRentingEvents = rentingEvents {
                let event = currentRentingEvents[indexPath.row]
                // check type of event and then get the right kind of table cell
                switch event.type {
                case .somebodyRented:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SomebodyRentedTableViewCell.identifier, for: indexPath) as! SomebodyRentedTableViewCell
                        // pass event to cell to fill the labels
                        cell.event = event
                        cell.delegate = self
                        return cell
                    
                case .youRented:
                    /*let cell = collectionView.dequeueReusableCell(withReuseIdentifier: YouRentedTableViewCell.identifier, for: indexPath) as! YouRentedTableViewCell
                        // pass event to cell to fill the labels

                        cell.delegate = self
                        return cell*/
                    print("fix later")
                    
                }
            }
            case self.usersOfferingsTable:
             if let currentUsersOfferings = usersOfferingsAndBrands {
             // initialisation of this cell is in this class as no special cell class is used here
             let (offering, brand) = currentUsersOfferings[indexPath.row]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: USER_OFFERINGS_TABLE_CELL_IDENTIFIER, for: indexPath) as! ProfileUsersOffersCollectionViewCell
                cell.offer = offering
                cell.eHomePageViewController = self
                cell.offerCarPrice.text = "max." + "\(offering.basePrice)" + " €"
                cell.offerCarBrand.text = brand.name
                
                let carImage: UIImage = UIImage(named: "carplaceholder")!
                cell.offerCarImg.maskCircle(anyImage: carImage)
                let CarImgUrl = URL(string: (offering.pictureURL))
                cell.offerCarImg.kf.setImage(with: CarImgUrl)

                return cell
             }
        case self.usersRentingsRequestsTable:
            if let currentUsersRentingRequests = usersRentingRequests {
                let somebodyRented = currentUsersRentingRequests[indexPath.row]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: USER_REQUESTS_TABLE_CELL_IDENTIFIER, for: indexPath) as! UserRentingRequestsTableViewCell
                    // pass event to cell to fill the labels
                    cell.somebodyRented = somebodyRented
                    cell.delegate = self
                    return cell
            }
        default:
            print("non-intended use of HomePageViewController as delegate for an unknown table view (in cellForRowAt)")
            return UICollectionViewCell()
        }
        return UICollectionViewCell()
    }
    

}


