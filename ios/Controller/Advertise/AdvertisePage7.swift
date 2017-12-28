//
//  AdvertisePage7.swift
//  ios
//
//  Created by admin on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class AdvertisePage7: UIViewController {
    
    @IBOutlet weak var publishButton: UIButton!
    
    @IBAction func publishNow(_ sender: Any) {
        let alertTest = UIAlertController(title: "Test", message: "This is a test", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
        alertTest.addAction(ok)
        present(alertTest, animated: true, completion: nil)
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
