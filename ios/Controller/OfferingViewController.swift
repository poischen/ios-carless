//
//  OfferingViewController.swift
//  ios
//
//  Created by Konrad Fischer on 17.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class OfferingViewController: UIViewController {
    
    var offeringToShow:Offering?

    override func viewDidLoad() {
        super.viewDidLoad()
        if offeringToShow != nil {
            print("yay, got the offering")
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
