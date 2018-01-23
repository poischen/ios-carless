//
//  ViewController.swift
//  show_inserat
//
//  Created by admin on 12.12.17.
//  Copyright © 2017 ioscars. All rights reserved.
//

import UIKit
import Kingfisher
import Cosmos
import MapKit

class OfferingViewController: UIViewController {
    
    var displayingOffering: Offering?
    let storageAPI = StorageAPI.shared
    let showOfferModel = ShowOffer()
    var preselectedEndDate: Date?
    var preselectedStartDate: Date?
    
    var lessor: User?
    
    //TODO Use featurelist from db
    let featuresDummy = ["AC", "navigation", "cruise_control"]
    
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var basicDataCollectionView: UICollectionView!
    var basicDetails: [String]?
    @IBOutlet weak var carHpConsumptionLabel: UILabel!
    @IBOutlet weak var lessorNameLabel: UILabel!
    @IBOutlet weak var lessorRateView: CosmosView!
    @IBOutlet weak var lessorProfileImageView: UIImageView!
    @IBOutlet weak var offerDescriptionTextView: UITextView!
    @IBOutlet weak var featuresCollectionView: UICollectionView!
    @IBOutlet weak var featuresCVSuperView: UILabel!
    var features: [String]?
    let regionRadius: CLLocationDistance = 200
    @IBOutlet weak var carLocationMap: MKMapView!
    @IBOutlet weak var pickUpLabel: UILabel!
    @IBOutlet weak var returnLabel: UILabel!
    @IBOutlet weak var availibilityBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var actionItem: UIBarButtonItem!
    @IBOutlet weak var priceLabel: UILabel!
    
    let identifierBasicDataCollectionView = "basicDetailsCollectionViewCell"
    let identifierFeaturesCollectionView = "featuresCollectionViewCell"
    
    let PICKUP_RETURN_DEFAULT = "00:00"
    let CURRENCY = "€"

    
    @IBAction func chatButton(_ sender: UIButton) {
        if let lessorUser = lessor {
            let storyboard = UIStoryboard(name: "ChatStoryboard", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChatWithUser") as! ChatWindowVC
            vc.selectedUser = lessorUser.id
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionItem(_ sender: Any) {
        // Offer is not the users own offer -> provide availibility check
        if (displayingOffering?.userUID != storageAPI.userID()) {
            let vc = storyboard?.instantiateViewController(withIdentifier: "Offering") as! AvailibilityAndBookingViewController
            //pass preselected dates -> in prepare function
            self.present(vc, animated: true, completion: nil)
            
        } else { // Offer is the users own offer -> provide deleting option
            guard let id = displayingOffering?.id else {
                let alert = UIAlertController(title: "Oh noes", message: "Something went wrong. Try again later.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
            let alert = UIAlertController(title: "Orly?", message: "Are you sure about deleting this awesome offering?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Yes please!",
                                          style: UIAlertActionStyle.default,
                                          handler: {(alert: UIAlertAction!) in
                                            self.storageAPI.deleteOfferingByID(offeringID: id)
                                            self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "NOPE!", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    //Switch to User Profile Storyboard when Lessor's Profile Image was tapped
    func tappedOnLessorImg() {
        if let lessorUser = lessor {
            let storyboard = UIStoryboard(name: "ProfileExternView", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ExternProfile") as! ExternProfileViewController
            vc.profileOwner = lessorUser
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         // Offer is not the users own offer -> provide availibility check
        if (displayingOffering?.userUID != storageAPI.userID()) {
            self.navigationItem.title = "Offer"
            actionItem.title = "Check Availibility"
        } else { // Offer is the users own offer
            self.navigationItem.title = "Preview"
            actionItem.image = UIImage(named: "icondelete")
            chatBtn.isEnabled = false
        }
        
        //set car infos (image, name, basic details) area --------------------------------------------------
        //images using Kingfisher
        carImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        carImageView.contentMode = .scaleAspectFill
        carImageView.clipsToBounds = true
        
        let CarImgUrl = URL(string: (displayingOffering?.pictureURL)!)!
        carImageView.kf.indicatorType = .activity
        carImageView.kf.setImage(with: CarImgUrl)
        
        //labels
        //carNameLabel.text = displayingOffering.getBrand() + " " + displayingOffering.type
        storageAPI.getBrandByID(id: (displayingOffering?.brandID)!, completion: { (brand) in
            self.carNameLabel.text = brand.name + " " + (self.displayingOffering?.type)!
        })
        
        carHpConsumptionLabel.text = "\(displayingOffering?.consumption ?? 0)" + "/100km, max. " + "\(displayingOffering?.hp ?? 0)" + " km/h."
        
        //detailicons
        showOfferModel.getBasicDetails(offer: displayingOffering!, completion: { (basicDetails) in
            self.basicDetails = basicDetails
            self.basicDataCollectionView.dataSource = self
        })
        
        //set information about lessor area-------------------------------------------------------------------------------------------------------------------------
        storageAPI.getUserByUID(UID: displayingOffering!.userUID) { (lessor) in
            print(lessor)
            self.lessor = lessor
            self.lessorNameLabel.text = lessor.name
            self.lessorRateView.rating = Double(lessor.rating)
            self.lessorRateView.text = String (lessor.rating)
            
            let lessorProfileImage: UIImage = UIImage(named: "user")!
            self.lessorProfileImageView.maskCircle(anyImage: lessorProfileImage)
            
            let profileImgUrl = URL(string: lessor.profileImgUrl)!
            self.lessorProfileImageView.kf.setImage(with: profileImgUrl)
        }

        let tapOnLessorImg = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnLessorImg))
        lessorProfileImageView.addGestureRecognizer(tapOnLessorImg)
        lessorProfileImageView.isUserInteractionEnabled = true

        
        //set information about further details and description area---------------------------------------------------
        offerDescriptionTextView.text = displayingOffering?.description
        let contentSize = offerDescriptionTextView.sizeThatFits(offerDescriptionTextView.bounds.size)
        var frame = offerDescriptionTextView.frame
        frame.size.height = contentSize.height
        offerDescriptionTextView.frame = frame
        
        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: offerDescriptionTextView, attribute: .height, relatedBy: .equal, toItem: offerDescriptionTextView, attribute: .width, multiplier: offerDescriptionTextView.bounds.height/offerDescriptionTextView.bounds.width, constant: 1)
        offerDescriptionTextView.addConstraint(aspectRatioTextViewConstraint)
        
        //set feature area---------------------------------------------------
        showOfferModel.getFeatures(offerID: displayingOffering!.id!, completion: { (features) in
            self.features = features
            self.basicDataCollectionView.dataSource = self
        })
        
        //set information for picking up the car (map & time) area---------------------------------------------------
        let latitude = Double((displayingOffering?.latitude)!)
        let longitude = Double((displayingOffering?.longitude)!)

        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        centerMapOnLocation(location: initialLocation)
        
        let carLocation = CarLocation(locationName: (displayingOffering?.location)!, discipline: "default", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: longitude))
        carLocationMap.addAnnotation(carLocation)
        
        if (displayingOffering?.pickupTime == ""){
            pickUpLabel.text = PICKUP_RETURN_DEFAULT
        } else {
            pickUpLabel.text = displayingOffering?.pickupTime
        }
        
        if (displayingOffering?.returnTime == ""){
            returnLabel.text = PICKUP_RETURN_DEFAULT
        } else {
            returnLabel.text = displayingOffering?.returnTime
        }
        
        priceLabel.text = "\(displayingOffering!.basePrice)" + CURRENCY

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Adjust hight of Description to Content Text
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGRect{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segueidentifier")
        print(segue.identifier ?? "defaultsegue")
        if segue.identifier == "availibilityCheckSegue" {
            let aNbVC: AvailibilityAndBookingViewController = segue.destination as! AvailibilityAndBookingViewController
            aNbVC.offer = displayingOffering
            if let psd = preselectedStartDate, let ped = preselectedEndDate {
                aNbVC.preselectedEndDate = psd
                aNbVC.preselectedEndDate = ped
            }
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        basicDataCollectionView.reloadData()
        featuresCollectionView.reloadData()
    }
    
    //set car location
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius, regionRadius)
        carLocationMap.setRegion(coordinateRegion, animated: true)
    }
    
}

//calc round images
extension UIImageView {
    public func maskCircle(anyImage: UIImage) {
        self.contentMode = UIViewContentMode.scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        
        self.image = anyImage
    }
}


extension OfferingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (collectionView == self.basicDataCollectionView){
            if let bd = basicDetails {
                return bd.count
            } else {
                print("No basic details yet")
                return 0
            }
        } else {
            if let f = features {
                return f.count
            } else {
                print("No features yet")
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.basicDataCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifierBasicDataCollectionView, for: indexPath) as! BasicDataCollectionViewCell
            if let bd = basicDetails{
                let basicDetail = bd[indexPath.row]
                if (indexPath.row == 0){ //seats
                    cell.displayContent(image: basicDetail, despcription: "\(basicDetail)" + " seats")
                }
                else {
                    cell.displayContent(image: basicDetail, despcription: "\(basicDetail)")
                }
            }

            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifierFeaturesCollectionView, for: indexPath) as! FeaturesCollectionViewCell
            if let f = features{
                let feature = f[indexPath.row]
                cell.displayContent(image: feature)
            }
            return cell
        }
        
    }

}
