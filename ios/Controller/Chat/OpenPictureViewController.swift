//
//  OpenPictureViewController.swift
//  ios
//
//  Created by Jelena Pranjic on 27.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit

class OpenPictureViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBAction func dismissPicView(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
