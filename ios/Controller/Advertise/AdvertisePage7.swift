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
        let alertTest = UIAlertController(title: "Test", message: "This is a test", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
        alertTest.addAction(ok)
        present(alertTest, animated: true, completion: nil)
        
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
                    strongSelf.pageViewController.offeringDict.updateValue(imgURL, forKey: Offering.OFFERING_PICTURE_URL_KEY)
                } else {
                    let message: String = "\(errorMassage) Please try again later."
                    let alert = UIAlertController(title: "Something went wrong :(", message: message, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    strongSelf.present(alert, animated: true, completion: nil)
                }
            //convert input values to DB-IDs
            //init offer dictionary
            //write offer to db
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = self.parent as! AdvertisePagesVC
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

/* upload image
 
 let imageName = "\(Date().timeIntervalSince1970).jpg"
 storageAPI.uploadImage(image, imageName: imageName, ref: storageAPI.offerImageStorageRef)
 //, progressBlock: <#T##(Double) -> Void#>, completionBlock: <#T##(URL?, String?) -> Void#>)
 
 */
