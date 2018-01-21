//
//  RatingsCollectionViewCell.swift
//  ios
//
//  Created by admin on 15.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import Cosmos

class RatingsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userRatingDescription: UITextView!
    @IBOutlet weak var userRatingStars: CosmosView!
}
