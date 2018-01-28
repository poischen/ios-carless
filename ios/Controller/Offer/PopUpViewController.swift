//
//  PopUpViewController.swift
//  ios
//
//  Created by Jelena Pranjic on 27.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit

class PopUpViewController: UIViewController {
    
    var carImage: UIImage?
    @IBOutlet weak var carImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = carImage {
            carImageView.image = image
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func popUpDismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
