//
//  AdvertisePage7.swift
//  ios
//
//  Created by admin on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class AdvertisePage7: UIViewController {
    
    var pageViewController: AdvertisePagesVC!
    let storageAPI = StorageAPI.shared
    
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBAction func publishNow(_ sender: Any) {
        //upload car image
        progressBar.isHidden = false
        progressLabel.isHidden = false
        storageAPI.uploadImage(pageViewController.carImage, ref: storageAPI.offerImageStorageRef, progressBar: progressBar, progressLabel: progressLabel,
            completionBlock: { [weak self] (fileURL, errorMassage) in
                guard let strongSelf = self else {
                    return
                }
            print(fileURL)
            print(errorMassage)
                
            //store image url
                if let imgURL: AnyObject = fileURL as? AnyObject {
                    //store image-url & user-id to offering
                    //init offer object
                    //write offer to db
                    let imageUrl = fileURL?.absoluteString
                    strongSelf.pageViewController.advertiseModel.updateDict(input: imageUrl as AnyObject, key: Offering.OFFERING_PICTURE_URL_KEY, needsConvertion: false, conversionType: "none")
                    strongSelf.pageViewController.advertiseModel.updateDict(input: strongSelf.storageAPI.userID() as AnyObject, key: Offering.OFFERING_USER_UID_KEY, needsConvertion: false, conversionType: "none")
                    print("OFFER DICT BEFORE PUBLISHING:")
                    print(strongSelf.pageViewController.advertiseModel.offeringDict)
                    strongSelf.pageViewController.writeOfferToDB()
                    
                } else {
                    let message: String = "\(errorMassage) Please try again later."
                    let alert = UIAlertController(title: "Something went wrong :(", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    strongSelf.present(alert, animated: true, completion: nil)
                }

        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController = self.parent as! AdvertisePagesVC

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
