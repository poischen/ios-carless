//
//  ProfileUsersOffersCollectionViewCell.swift
//  ios
//
//  Created by admin on 15.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit

class ProfileUsersOffersCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var offerCarImg: UIImageView!
    @IBOutlet weak var offerCarName: UILabel!
    @IBOutlet weak var offerCarPrice: UILabel!
    
    var offer: Offering?
    var eProfileViewController: ExternProfileViewController?
    
    @IBAction func moreDetailsButton(_ sender: Any) {
        if let offer = self.offer, let eProfileViewController = self.eProfileViewController {
            eProfileViewController.presentOfferView(offer: offer)
        }
    }
    
}
