//
//  AdvertisePage6.swift
//  ios
//
//  Created by admin on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class AdvertisePage6: UIViewController, UITextViewDelegate {

    var pageViewController: AdvertisePagesVC!
    let storageAPI = StorageAPI.shared
    
    @IBOutlet weak var rentalDescriptionTextView: UITextView!
    var descriptionText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = self.parent as! AdvertisePagesVC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        //descriptionText = textView.text
        pageViewController.advertiseModel.updateDict(input: textView.text as AnyObject, key: Offering.OFFERING_DESCRIPTION_KEY, needsConvertion: false, conversionType: "none")
    }
    
  /*  func textViewDidChange(_ textView: UITextView) {
        descriptionText = textView.text
        pageViewController.advertiseModel.updateDict(input: descriptionText as AnyObject, key: Offering.OFFERING_DESCRIPTION_KEY, needsConvertion: false, conversionType: "none")
    } */
   
}
