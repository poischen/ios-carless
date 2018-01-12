//
//  BasicDataCollectinViewCell.swift
//  show_inserat
//
//  Created by admin on 12.12.17.
//  Copyright © 2017 ioscars. All rights reserved.
//

import UIKit

class BasicDataCollectionViewCell: UICollectionViewCell{
    
    @IBOutlet var basicDetailImageView: UIImageView!
    @IBOutlet var basicDetailLabel: UILabel!
    
    func displayContent(image: String, despcription: String){
        let icon : UIImage = UIImage(named:image)!
        basicDetailImageView.image = icon
        basicDetailLabel.text = despcription
    }

}
