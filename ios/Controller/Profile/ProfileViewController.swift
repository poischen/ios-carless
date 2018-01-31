//
//  ExternProfileViewController.swift
//  ios
//
//  Created by admin on 14.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Cosmos

class ProfileViewController: UIViewController {
    let storageAPI = StorageAPI.shared
    
    @IBOutlet weak var profileOwnerImageView: UIImageView!
    @IBOutlet weak var profileOwnerName: UILabel!
    @IBOutlet weak var noCurrentOfferNote: UILabel!
    @IBOutlet weak var noCurrentRatingsNote: UILabel!
    @IBOutlet weak var profileOwnerRatingStars: CosmosView!
    @IBOutlet weak var otherUsersAboutProfileOwnerHL: UILabel!
    @IBOutlet weak var profileOwnersCurrentOffersHL: UILabel!
    @IBOutlet weak var collectionViewRatings: UICollectionView!
    @IBOutlet weak var collectionViewOffers: UICollectionView!
    @IBOutlet weak var profileImageUploadProgress: UIProgressView!
    
    var cancelButtonNeeded = false
    
    static let PROFILE_NAVIGATION_IDENTIFIER = "NavProfile"
    static let PROFILE_STORYBOARD_IDENTIFIER = "Profile"
    
    let collectionViewRatingsIdentifier = "RatingsCollectionViewCell"
    let collectionViewOffersIdentifier = "OffersCollectionViewCell"
    
    let ratinsHL = "Other users about "
    let offersHL = "'s current offers"
    let fromString = "from "
    let currencyString = " €"
    let title3rd = "'s Profile"
    let titleOwn = "Your Profile"
    
    var profileOwner: User?
    var usersRatings: [Rating]?
    var usersOffers: [Offering]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileOwnerImageView.maskCircle(anyImage: profileOwnerImageView.image!)
        profileOwnerImageView.layer.borderWidth = 1
        profileOwnerImageView.layer.borderColor = UIColor.black.cgColor
        
        if profileOwner == nil {
            storageAPI.getUserByUID(UID: storageAPI.userID()!, completion: { (user) in
                self.profileOwner = user
                self.setup(user: user)
            })
        } else {
            self.setup(user: self.profileOwner!)
        }
        
    }
    
    func setup(user: User) {
            if user.id == storageAPI.userID() { //profile belongs to user -> enable logout and change profile pic
                self.navigationItem.title = titleOwn
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTapped))
                
            } else { //profile belongs to another user
                self.navigationItem.title = user.name + title3rd
            }
            
            if cancelButtonNeeded {
                navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
                self.tabBarController?.tabBar.isHidden = true
            }
            
            storageAPI.getUserProfileImageUrl(uID: user.id) { (path) in
                let profileImgUrl = URL(string: path)
                self.profileOwnerImageView.kf.indicatorType = .activity
                self.profileOwnerImageView.kf.setImage(with: profileImgUrl)
                
                if user.id == self.storageAPI.userID() {
                    let profileImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.profileImageTapped(tapGestureRecognizer:)))
                    self.profileOwnerImageView.isUserInteractionEnabled = true
                    self.profileOwnerImageView.addGestureRecognizer(profileImageTapGestureRecognizer)
                }
            }
            let name = user.name
            otherUsersAboutProfileOwnerHL.text = ratinsHL + name
            profileOwnersCurrentOffersHL.text = name + offersHL
            
            profileOwnerName.text = name
            profileOwnerRatingStars.rating = (Double) (user.rating)
            
            storageAPI.getRatingsByUserUID(userUID: user.id) { (ratings) in
                self.usersRatings = ratings
                self.collectionViewRatings.dataSource = self
                self.collectionViewRatings.reloadData()
            }
            
            storageAPI.getOfferingsByUserUID(userUID: user.id, completion: { (offerings) in
                self.usersOffers = offerings
                self.collectionViewOffers.dataSource = self
                self.collectionViewOffers.reloadData()
            })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func logoutTapped(){
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Main")
        self.present(vc, animated: true, completion: nil)
    }
    
    func profileImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: . actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
                
                
            }else {
                print ("Camera not available")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated:true, completion:nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler:nil ))
        
        self.present(actionSheet, animated: true, completion:nil)
    }
    
    /*
     * Upload new profile image to Storage and hand it to Database
     * Show Image in View
     */
    func uploadImage(image: UIImage){
        profileImageUploadProgress.isHidden = false
        storageAPI.uploadImage(image, ref: storageAPI.profileImageStorageRef, progressBar: profileImageUploadProgress, progressLabel: nil,
                               completionBlock: { [weak self] (fileURL, errorMassage) in
                                guard let strongSelf = self else {
                                    return
                                }
                                //store image url to user
                                if let imgURL = fileURL {
                                    strongSelf.profileImageUploadProgress.isHidden = true
                                    let imageUrl = imgURL.absoluteString
                                    strongSelf.storageAPI.updateUserProfilePicture(userID: strongSelf.profileOwner!.id, imgUrl: imageUrl)
                                    strongSelf.profileOwnerImageView.image = image
                                } else {
                                    strongSelf.profileImageUploadProgress.isHidden = true
                                    let message: String = "\(errorMassage ?? "") Please try again later."
                                    let alert = UIAlertController(title: "Something went wrong :(", message: message, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    strongSelf.present(alert, animated: true, completion: nil)
                                }
        })
        
    }
    
    func presentOfferView(offer: Offering){
        let storyboard = UIStoryboard(name: "Offering", bundle: nil)
        guard let navigationController = storyboard.instantiateViewController(withIdentifier: "OfferingNavigation") as? UINavigationController,
            let targetController = navigationController.topViewController as? OfferingViewController else {
                return
        }
        targetController.displayingOffering = offer
        self.present(navigationController, animated: true, completion: nil)
    }
    
    
}


extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionViewRatings {
            if let ratings = usersRatings {
                return ratings.count
            } else {
                noCurrentRatingsNote.isHidden = false
                return 0
            }
        } else {
            if let offers = usersOffers {
                return offers.count
            } else {
                noCurrentOfferNote.isHidden = false
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionViewRatings {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.collectionViewRatingsIdentifier, for: indexPath) as! RatingsCollectionViewCell
            if let ur = usersRatings {
                let rating = ur[indexPath.row] as Rating
                cell.userRatingDescription.text = rating.explanation
                cell.userRatingStars.rating = Double(rating.rating)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.collectionViewOffersIdentifier, for: indexPath) as! ProfileUsersOffersCollectionViewCell
            if let uo = usersOffers {
                cell.eProfileViewController = self
                let offer = uo[indexPath.row] as Offering
                cell.offer = offer
                let imgUrl: URL = URL(string: offer.pictureURL)!
                cell.offerCarImg.kf.indicatorType = .activity
                cell.offerCarImg.kf.setImage(with: imgUrl)
                cell.offerCarPrice.text = fromString + String(offer.basePrice) + currencyString
            }
            return cell
        }
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        uploadImage(image: selectedImage)
        picker.dismiss(animated:true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion:nil)
    }
}
