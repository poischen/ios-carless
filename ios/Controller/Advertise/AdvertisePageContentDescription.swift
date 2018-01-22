//
//  AdvertisePage6.swift
//  ios
//
//  Created by admin on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class AdvertisePageContentDescription: UIViewController, UITextViewDelegate {

    var pageViewController: AdvertisePagesVC!
    let storageAPI = StorageAPI.shared
    
    @IBOutlet weak var rentalDescriptionTextView: UITextView!
    var descriptionText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = self.parent as! AdvertisePagesVC
        rentalDescriptionTextView.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView){
        pageViewController.advertiseHelper.description = textView.text
    }

}
