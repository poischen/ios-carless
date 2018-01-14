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
    
    //todo: add nav bar items depending on users role to offer http://rshankar.com/navigation-controller-in-ios/
    
    let lessor = User(id: "profile123", name: "Markus", email: "markus@test.de", rating: 3.5, profileImgUrl: "https://firebasestorage.googleapis.com/v0/b/ioscars-32e69.appspot.com/o/icons%2Fplaceholder%2Fuser.jpg?alt=media&token=5fd1a131-29d6-4a43-8d17-338590e01808", numberOfRatings: 3)
    
    //TODO Use featurelist from db
    let featuresDummy = ["AC", "navigation", "cruise_control"]
    
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var basicDataCollectionView: UICollectionView!
    var basicDetails: [String] = []
    @IBOutlet weak var carHpConsumptionLabel: UILabel!
    @IBOutlet weak var lessorNameLabel: UILabel!
    @IBOutlet weak var lessorRateView: CosmosView!
    @IBOutlet weak var lessorProfileImageView: UIImageView!
    @IBOutlet weak var offerDescriptionTextView: UITextView!
    @IBOutlet weak var featuresCollectionView: UICollectionView!
    var features: [String] = []
    let regionRadius: CLLocationDistance = 20
    @IBOutlet weak var carLocationMap: MKMapView!
    @IBOutlet weak var pickUpLabel: UILabel!
    @IBOutlet weak var returnLabel: UILabel!
    @IBOutlet weak var availibilityBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var actionItem: UIBarButtonItem!
    
    @IBAction func chatButton(_ sender: UIButton) {
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil);
    }
    
    /*@IBAction func checkAvailibility(_ sender: Any) {
        let anbVC = AvailibilityAndBookingViewController(
            nibName: "AvailibilityAndBooking",
            bundle: nil)
        navigationController?.pushViewController(anbVC,
                                                 animated: true)
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

         // Offer is not the users own offer -> provide availibility check
        if (displayingOffering?.userUID != storageAPI.userID()) {
            self.navigationItem.title = "Offer"
            actionItem.title = "Check Availibility"
            //todo
        } else { // Offer is the users own offer -> provide deleting option
            self.navigationItem.title = "Preview "
            //todo
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
        
        basicDetails = showOfferModel.getBasicDetails(offer: displayingOffering!)
        basicDataCollectionView.dataSource = self
        
        //set information about lessor area---------------------------------------------------
        //todo: get user from offering
        lessorNameLabel.text = lessor.name
        lessorRateView.rating = Double(lessor.rating)
        lessorRateView.text = String (lessor.rating)
        
        let lessorProfileImage: UIImage = UIImage(named: "user")!
        lessorProfileImageView.maskCircle(anyImage: lessorProfileImage)
        
        let profileImgUrl = URL(string: lessor.profileImgUrl)!
        lessorProfileImageView.kf.setImage(with: profileImgUrl)
        
        //set information about further details and description area---------------------------------------------------
        offerDescriptionTextView.text = displayingOffering?.description
        let contentSize = offerDescriptionTextView.sizeThatFits(offerDescriptionTextView.bounds.size)
        var frame = offerDescriptionTextView.frame
        frame.size.height = contentSize.height
        offerDescriptionTextView.frame = frame
        
        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: offerDescriptionTextView, attribute: .height, relatedBy: .equal, toItem: offerDescriptionTextView, attribute: .width, multiplier: offerDescriptionTextView.bounds.height/offerDescriptionTextView.bounds.width, constant: 1)
        offerDescriptionTextView.addConstraint(aspectRatioTextViewConstraint)
        
        //set feature area---------------------------------------------------
        //features = displayingOffering.getFeatures() //TODO
        features = featuresDummy
        featuresCollectionView.dataSource = self
        self.view.addSubview(featuresCollectionView)
        
        //set information for picking up the car (map & time) area---------------------------------------------------
        let latitude = Double((displayingOffering?.latitude)!)
        let longitude = Double((displayingOffering?.longitude)!)
        //let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        //TODO  centerMapOnLocation(location: initialLocation)
        
        let carLocation = CarLocation(locationName: (displayingOffering?.location)!, discipline: "default", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: longitude))
        carLocationMap.addAnnotation(carLocation)
        
        pickUpLabel.text = displayingOffering?.pickupTime
        returnLabel.text = displayingOffering?.returnTime
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    //Switch to User Profile Storyboard when Lessor's Profile Image was tapped
    @IBAction func lessorProfileTap(_ sender: UITapGestureRecognizer) {
        print("Profilepic was touched")
        //TODO switch
        //let viewController:UIViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as UIViewController
        //self.present(viewController, animated: false, completion: nil)
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
    
    //MARK:- PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segueidentifier")
        print(segue.identifier ?? "")
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
            return basicDetails.count
        } else {
            return features.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.basicDataCollectionView {
            let cell = basicDataCollectionView.dequeueReusableCell(withReuseIdentifier: "basicDetailsCollectionViewCell", for: indexPath) as! BasicDataCollectionViewCell
            cell.awakeFromNib()
            return cell
        }
        else {
            let cell = featuresCollectionView.dequeueReusableCell(withReuseIdentifier: "featuresCollectionViewCell", for: indexPath) as! FeaturesCollectionViewCell
            cell.awakeFromNib()
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == self.basicDataCollectionView {
            let basiDetailCell = cell as! BasicDataCollectionViewCell
            let basicDetail = basicDetails[indexPath.row]
            
            print("basicDetail")
            print(basicDetail)
            
            if (indexPath.row == 0){ //seats
                basiDetailCell.displayContent(image: basicDetail, despcription: "")
            }
            else {
                //todo: was, wenn icon nicht local vorhanden? woher download url?
                basiDetailCell.displayContent(image: basicDetail, despcription: "")
            }
            basiDetailCell.awakeFromNib()
        }
            
        else {
            //TODO
            let featureCell = cell as! FeaturesCollectionViewCell
            let feature = features[indexPath.row]
            featureCell.displayContent(image: feature)
            featureCell.awakeFromNib()
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
