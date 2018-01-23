//
//  AdvertisePage7.swift
//  ios
//
//  Created by admin on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class AdvertisePageContentPublish: UIViewController {
    
    var pageViewController: AdvertisePagesVC!
    let storageAPI = StorageAPI.shared
    
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBAction func publishNow(_ sender: Any) {
        //upload car image
        progressBar.isHidden = false
        progressLabel.isHidden = false
        if pageViewController.carImage != nil {
            storageAPI.uploadImage(pageViewController.carImage, ref: storageAPI.offerImageStorageRef, progressBar: progressBar, progressLabel: progressLabel,
                                   completionBlock: { [weak self] (fileURL, errorMassage) in
                                    guard let strongSelf = self else {
                                        return
                                    }
                                    //store image url
                                    if let imgURL = fileURL as AnyObject? {
                                        //store image-url & user-id to offering
                                        //init offer object
                                        //write offer to db
                                        let imageUrl = imgURL.absoluteString
                                        strongSelf.pageViewController.advertiseHelper.pictureURL = imageUrl!
                                        strongSelf.pageViewController.advertiseHelper.userUID = strongSelf.storageAPI.userID()
                                        strongSelf.pageViewController.writeOfferToDB()
                                        
                                    } else {
                                        let message: String = "\(errorMassage ?? "") Please try again later."
                                        let alert = UIAlertController(title: "Something went wrong :(", message: message, preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        strongSelf.present(alert, animated: true, completion: nil)
                                    }
                                    
            })
        } else {
            let message: String = "Image is missing."
            let alert = UIAlertController(title: "Please provide an image of your car :)", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
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
