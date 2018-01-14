//
//  ExternProfileViewController.swift
//  ios
//
//  Created by admin on 14.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class ExternProfileViewController: UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.black.cgColor
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
}

