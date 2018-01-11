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
    
    func displayContent(image: String){
        
        let icon : UIImage = UIImage(named:image)!
        featureImageView.image = icon

    }
    
}
