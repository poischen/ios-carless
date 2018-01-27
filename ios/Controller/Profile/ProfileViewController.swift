//
//  ProfileViewController.swift
//  ios
//
//  Created by Hila Safi on 19.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import Kingfisher
import Cosmos

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let storageAPI = StorageAPI.shared
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileImageUploadProgress: UIProgressView!
    @IBOutlet weak var profileStars: CosmosView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingsCollectionView: UICollectionView!
    
    var usersRatings: [Rating]?
    var user: User?
    
    let collectionViewRatingsIdentifier = "RatingsCollectionViewCell"

    let userUID = StorageAPI.shared.userID()
    
    @IBAction func chooseImage(_ sender: Any) {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        uploadImage(image: selectedImage)
        picker.dismiss(animated:true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion:nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        handleLogout()
    }
    
    func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Main")
        self.present(vc, animated: true, completion: nil)
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
                                    strongSelf.storageAPI.updateUserProfilePicture(userID: strongSelf.storageAPI.userID(), imgUrl: imageUrl)
                                    strongSelf.profileImage.image = image
                                } else {
                                    strongSelf.profileImageUploadProgress.isHidden = true
                                    let message: String = "\(errorMassage ?? "") Please try again later."
                                    let alert = UIAlertController(title: "Something went wrong :(", message: message, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                    strongSelf.present(alert, animated: true, completion: nil)
                                }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImage.maskCircle(anyImage: profileImage.image!)
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.black.cgColor
        
        storageAPI.getUserProfileImageUrl(uID: storageAPI.userID()) { (path) in
            let profileImgUrl = URL(string: path)
            self.profileImage.kf.indicatorType = .activity
            self.profileImage.kf.setImage(with: profileImgUrl)
        }
        
        storageAPI.getUserByUID(UID: storageAPI.userID(), completion: {user in
            self.user = user
            self.nameLabel.text = user.name
            self.profileStars.rating = (Double) (user.rating)
            
        })
        
        storageAPI.getRatingsByUserUID(userUID: storageAPI.userID(), completion: {ratings in
            self.usersRatings = ratings
        })
        
        print (usersRatings)
        print ("second user ratings")
        
       if Auth.auth().currentUser?.uid == nil {
         handleLogout()
         }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let ratings = usersRatings {
            return ratings.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.collectionViewRatingsIdentifier, for: indexPath) as! RatingsCollectionViewCell
            if let ur = usersRatings {
                let rating = ur[indexPath.row] as Rating
                cell.userRatingDescription.text = rating.explanation
                cell.userRatingStars.rating = Double(rating.rating)
            }
            return cell
        
    }
}


