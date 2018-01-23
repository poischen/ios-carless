//
//  AdvertisePopOverPhotoViewController.swift
//  ios
//
//  Created by admin on 23.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit

class AdvertisePopOverPhotoViewController: UIViewController {

    @IBOutlet weak var carImage: UIImageView!
    
    override func viewDidLoad() {
        carImage.contentMode = .scaleAspectFit
    }

}
