//
//  ExternProfileViewController.swift
//  ios
//
//  Created by admin on 14.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Cosmos

class ExternProfileViewController: UIViewController {
    let storageAPI = StorageAPI.shared
    
    @IBOutlet weak var profileOwnerImageView: UIImageView!
    @IBOutlet weak var profileOwnerName: UILabel!
    @IBOutlet weak var noCurrentOfferNote: UILabel!
    @IBOutlet weak var noCurrentRatingsNote: UILabel!
    @IBOutlet weak var profileOwnerRatingStars: CosmosView!
    @IBOutlet weak var otherUsersAboutProfileOwnerHL: UILabel!
    @IBOutlet weak var profileOwnersCurrentOffersHL: UILabel!
    @IBOutlet weak var collectionViewRatings: UICollectionView!
    @IBOutlet weak var collectionViewOffers: UICollectionView!

    let collectionViewRatingsIdentifier = "RatingsCollectionViewCell"
    let collectionViewOffersIdentifier = "OffersCollectionViewCell"
    
    let ratinsHL = "Other users about "
    let offersHL = "'s current offers"
    let fromString = "from "
    let currencyString = " €"
    
    var profileOwner: User?
    var usersRatings: [Rating]?
    var usersOffers: [Offering]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileOwnerImageView.layer.cornerRadius = profileOwnerImageView.frame.size.width / 2
        profileOwnerImageView.clipsToBounds = true
        profileOwnerImageView.layer.borderWidth = 1
        profileOwnerImageView.layer.borderColor = UIColor.black.cgColor
        
        if let user = profileOwner {
            storageAPI.getUserProfileImageUrl(uID: user.id) { (path) in
                let profileImgUrl = URL(string: path)
                self.profileOwnerImageView.kf.indicatorType = .activity
                self.profileOwnerImageView.kf.setImage(with: profileImgUrl)
            }
            let name = user.name
            otherUsersAboutProfileOwnerHL.text = ratinsHL + name
            profileOwnersCurrentOffersHL.text = name + offersHL
            
            profileOwnerName.text = name
            profileOwnerRatingStars.rating = (Double) (user.rating)
         
            storageAPI.getRatingsByUserUID(userUID: profileOwner!.id) { (ratings) in
                self.usersRatings = ratings
            }
            
            storageAPI.getOfferingsByUserUID(userUID: profileOwner!.id, completion: { (offerings) in
                self.usersOffers = offerings
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension ExternProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionViewRatings {
            if let ratings = usersRatings {
                return ratings.count
            } else {
                noCurrentRatingsNote.isHidden = false
                return 0
            }
        } else {
            if let offers = usersOffers {
                return offers.count
            } else {
                noCurrentOfferNote.isHidden = false
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionViewRatings {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.collectionViewRatingsIdentifier, for: indexPath) as! RatingsCollectionViewCell
            if let ur = usersRatings {
                let rating = ur[indexPath.row] as Rating
                cell.userRatingDescription.text = rating.explanation
                cell.userRatingStars.rating = Double(rating.rating)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.collectionViewOffersIdentifier, for: indexPath) as! ProfileUsersOffersCollectionViewCell
            if let uo = usersOffers {
                cell.eProfileViewController = self
                let offer = uo[indexPath.row] as Offering
                cell.offer = offer
                let imgUrl: URL = URL(string: offer.pictureURL)!
                cell.offerCarImg.kf.indicatorType = .activity
                cell.offerCarImg.kf.setImage(with: imgUrl)
                cell.offerCarName.text = offer.type
                cell.offerCarPrice.text = fromString + String(offer.basePrice) + currencyString
            }
            return cell
        }
    }
}
