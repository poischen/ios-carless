//
//  AdvertisePage6.swift
//  ios
//
//  Created by admin on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class AdvertisePage6: UIViewController, UITextViewDelegate {

    @IBOutlet weak var rentalDescriptionTextView: UITextView!
    var descriptionText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        descriptionText = textView.text
        print("end " + descriptionText)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        descriptionText = textView.text
        print("change " + descriptionText)
    }
   
}
