//
//  ProfileUsersOffersCollectionViewCell.swift
//  ios
//
//  Created by admin on 15.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import ScalingCarousel

class ProfileUsersOffersCollectionViewCell: ScalingCarouselCell {
    @IBOutlet weak var offerCarImg: UIImageView!
    @IBOutlet weak var offerCarBrand: UILabel!
    @IBOutlet weak var offerCarPrice: UILabel!
    
    var offer: Offering?
    var eProfileViewController: ProfileViewController?
    var eHomePageViewController: HomePageViewController?
    
    @IBAction func moreDetailsButton(_ sender: Any) {
        if let offer = self.offer, let eProfileViewController = self.eProfileViewController {
            eProfileViewController.presentOfferView(offer: offer)
        }
        if let offer = self.offer, let eHomePageViewController = self.eHomePageViewController {
            eHomePageViewController.presentOfferView(offer: offer)
        }
    }
    
}
