//
//  FeaturesCollectionViewCell.swift
//  show_inserat
//
//  Created by admin on 13.12.17.
//  Copyright © 2017 ioscars. All rights reserved.
//

import UIKit

class FeaturesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var featureImageView: UIImageView!
    
    func displayContent(feature: Feature){
        
        if let icon : UIImage = UIImage(named: feature.name){
            featureImageView.image = icon
        }
        else {
            let iconUrl = URL(string: (feature.iconURL))
            featureImageView.kf.indicatorType = .activity
            featureImageView.kf.setImage(with: iconUrl)
        }

    }
    
}
