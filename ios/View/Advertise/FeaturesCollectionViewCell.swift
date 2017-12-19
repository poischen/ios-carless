//
//  FeaturesCollectionViewCell.swift
//  advertise
//
//  Created by admin on 08.12.17.
//  Copyright © 2017 ioscars. All rights reserved.
//

import UIKit

class FeaturesCollectionViewCell: UICollectionViewCell {
    
    var featureIconImageView: UIImageView!
    var featureLabel: UILabel!
    
    override func awakeFromNib() {
        featureIconImageView = UIImageView(frame: contentView.frame)
        featureIconImageView.contentMode = .scaleToFill
        featureIconImageView.clipsToBounds = true
        
        featureLabel = UILabel(frame: contentView.frame)
        
        contentView.addSubview(featureIconImageView)
        contentView.addSubview(featureLabel)
    }
}

