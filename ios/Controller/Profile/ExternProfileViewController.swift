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
    @IBOutlet weak var profileOwnerRatingStars: CosmosView!
    @IBOutlet weak var otherUsersAboutProfileOwnerHL: UILabel!
    @IBOutlet weak var profileOwnersCurrentOffersHL: UILabel!
    @IBOutlet weak var collectionViewRatings: UICollectionView!
    @IBOutlet weak var collectionViewOffers: UICollectionView!

    let collectionViewRatingsIdentifier = "RatingsCollectionViewCell"
    let collectionViewOffersIdentifier = "OffersCollectionViewCell"
    
    let ratinsHL = "Other users about "
    let offersHL = " current offers"
    
    var profileOwner: User?
    
    //todo: use data from db
    let ratingNames = ["Hans", "Dieter", "Claudia"]
    let ratingDescriptions = ["Hat alles super geklappt, vielen Dank!", "1 geile Karre so vong Niceigkeit her!", "Hervorragendes Auto für den Sonntags-Fammilienausflug. Ich bin mit meinem Mann und meinen zwei Töchtern bis in die Fränkische Schweiz gefahren. Mit der Übergabe von und an Daniel war alles bestens."]
    let ratingStars: [Double] = [4, 5, 5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileOwnerImageView.layer.cornerRadius = profileOwnerImageView.frame.size.width / 2
        profileOwnerImageView.clipsToBounds = true
        profileOwnerImageView.layer.borderWidth = 2
        profileOwnerImageView.layer.borderColor = UIColor.black.cgColor
        
        if let user = profileOwner {
            storageAPI.getUserProfileImageUrl(uID: user.id) { (path) in
                let profileImgUrl = URL(string: path)
                self.profileOwnerImageView.kf.indicatorType = .activity
                self.profileOwnerImageView.kf.setImage(with: profileImgUrl)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
}

extension ExternProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionViewRatings {
            return ratingNames.count
        } else {
            return 0 //todo
        }
    }
    
    //TODO: implement collectionView:willDisplayCell:forItemAtIndexPath: ???
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionViewRatings {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.collectionViewRatingsIdentifier, for: indexPath) as! RatingsCollectionViewCell
            
            cell.userName.text = self.ratingNames[indexPath.row] + ":"
            cell.userRatingDescription.text = self.ratingDescriptions[indexPath.row]
            cell.userRatingStars.rating = self.ratingStars[indexPath.row]
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.collectionViewOffersIdentifier, for: indexPath) as! ProfileUsersOffersCollectionViewCell
            //todo: fill cell
            return cell
        }
    }
}
