//
//  circleImages.swift
//  ios
//
//  Created by admin on 25.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit

//calc round images
extension UIImageView {
    public func maskCircle(anyImage: UIImage) {
        self.contentMode = UIViewContentMode.scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        
        self.image = anyImage
    }
}
