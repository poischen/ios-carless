//
//  RatingsCollectionViewCell.swift
//  ios
//
//  Created by admin on 15.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import Cosmos
import ScalingCarousel

class RatingsCollectionViewCell: ScalingCarouselCell {
    
    @IBOutlet weak var userRatingDescription: UITextView!
    @IBOutlet weak var userRatingStars: CosmosView!
}
