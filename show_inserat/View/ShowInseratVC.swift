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

class ShowInseratVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //TODO use DB-Data instead of Dummys
    let displayingOffering = Offering(id: 1, basePrice: 120, brand: "BMW", name: "X5", consumption: 7, description: "I am a Description.\n\nWeit hinten, hinter den Wortbergen, fern der Länder Vokalien und Konsonantien leben die Blindtexte. Abgeschieden wohnen sie in Buchstabhausen an der Küste des Semantik, eines großen Sprachozeans. Ein kleines Bächlein namens Duden fließt durch ihren Ort und versorgt sie mit den nötigen Regelialien. Es ist ein paradiesmatisches Land, in dem einem gebratene Satzteile in den Mund fliegen.\n\nRent this car, it's georgious!", fuel: "gas", gear: "manual", hp: 230, latitude: 11.581981, location: "Munich", longitude: 48.135125, pictureURL: "https://firebasestorage.googleapis.com/v0/b/ioscars-32e69.appspot.com/o/icons%2Fplaceholder%2Fcar.jpg?alt=media&token=168e6d4e-ee84-4f56-817b-b7ec1971d6ba", seats: 5, type: "SUV", featuresIDs: [1, 2, 3], vehicleTypeID: 5, vehicleType: "SUV")
    
    let lessor = UserProfile(id: "profile123", name: "Markus", profileImgUrl: "https://firebasestorage.googleapis.com/v0/b/ioscars-32e69.appspot.com/o/icons%2Fplaceholder%2Fuser.jpg?alt=media&token=5fd1a131-29d6-4a43-8d17-338590e01808", rating: 3.5)
    
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
    @IBOutlet var featuresCollectionView: UICollectionView!
    var features: [String] = []
    let regionRadius: CLLocationDistance = 2000
    @IBOutlet weak var carLocationMap: MKMapView!
    @IBAction func chatButton(_ sender: UIButton) {
        //TODO: Controller.chat()
    }
    @IBAction func checkAvailibility(_ sender: Any) {
        //TODO: Controller.checkAvailibility()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        //set car infos (image, name, basic details) area --------------------------------------------------
        //images using Kingfisher
        carImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        carImageView.contentMode = .scaleAspectFill
        carImageView.clipsToBounds = true
        
        let CarImgUrl = URL(string: displayingOffering.pictureURL)!
        //let placeholderImg = UIImage(named: "carplaceholder")
        //carImageView.kf.setImage(with: imgUrl, placeholder: implaceholderImgage)
        carImageView.kf.indicatorType = .activity
        carImageView.kf.setImage(with: CarImgUrl)
        
        //labels
        carNameLabel.text = displayingOffering.brand + " " + displayingOffering.name
        carHpConsumptionLabel.text = "\(displayingOffering.consumption)" + " l/100km, max. " + "\(displayingOffering.hp)" + " km/h."
        
        //detailicons
        basicDetails = displayingOffering.getBasicDetails()
        
        // Initialize the collection views, set the desired frames
        basicDataCollectionView.delegate = self
        basicDataCollectionView.dataSource = self
        self.view.addSubview(basicDataCollectionView)
        
        //set information about lessor area---------------------------------------------------
        lessorNameLabel.text = lessor.name
        lessorRateView.rating = Double(lessor.rating)
        lessorRateView.text = String (lessor.rating)
        
        let lessorProfileImage: UIImage = UIImage(named: "user")!
        lessorProfileImageView.maskCircle(anyImage: lessorProfileImage)
        
        let profileImgUrl = URL(string: lessor.profileImgUrl)!
        lessorProfileImageView.kf.setImage(with: profileImgUrl)
        
        //set information about further details and description area---------------------------------------------------
        offerDescriptionTextView.text = displayingOffering.description
        let contentSize = offerDescriptionTextView.sizeThatFits(offerDescriptionTextView.bounds.size)
        var frame = offerDescriptionTextView.frame
        frame.size.height = contentSize.height
        offerDescriptionTextView.frame = frame
        
        let aspectRatioTextViewConstraint = NSLayoutConstraint(item: offerDescriptionTextView, attribute: .height, relatedBy: .equal, toItem: offerDescriptionTextView, attribute: .width, multiplier: offerDescriptionTextView.bounds.height/offerDescriptionTextView.bounds.width, constant: 1)
        offerDescriptionTextView.addConstraint(aspectRatioTextViewConstraint)
        
        //set feature area---------------------------------------------------
        //features = displayingOffering.getFeatures() //TODO
        features = featuresDummy
        featuresCollectionView.delegate = self
        featuresCollectionView.dataSource = self
        self.view.addSubview(featuresCollectionView)
        
        
        //set information for picking up the car (map & time) area---------------------------------------------------
        let latitude = Double(displayingOffering.latitude)
        let longitude = Double(displayingOffering.longitude)
        let initialLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        centerMapOnLocation(location: initialLocation)
        
        let carLocation = CarLocation(locationName: displayingOffering.location, discipline: "default", coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: longitude))
        carLocationMap.addAnnotation(carLocation)
        
        //TODO Labels with pickup time
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.basicDataCollectionView {
            return basicDetails.count
        }
        return self.features.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        if collectionView == self.basicDataCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "basicDetailsCollectionViewCell", for: indexPath) as! BasicDataCollectinViewCell
            
            let basicDetail = basicDetails[indexPath.row]
            cell.displayContent(image: basicDetail, despcription: basicDetail)
            print(basicDetail)
            
            return cell
        }
            
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "featuresCollectionViewCell", for: indexPath) as! FeaturesCollectionViewCell
            
            let feature = features[indexPath.row]
            cell.displayContent(image: feature)
            print(feature)
            
            return cell
        }
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

