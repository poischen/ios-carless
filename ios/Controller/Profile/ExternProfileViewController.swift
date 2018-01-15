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


class ExternProfileViewController: UIViewController {
    let storageAPI = StorageAPI.shared
    
    @IBOutlet weak var imageView: UIImageView!
    
    var profileOwner: User?
    
    //todo: use data from db
    let ratingNames = ["Hans", "Dieter", "Claudia"]
    let ratingDescriptions = ["Hat alles super geklappt, vielen Dank!", "1 geile Karre so vong Niceigkeit her!", "Hervorragendes Auto für den Sonntags-Fammilienausflug. Ich bin mit meinem Mann und meinen zwei Töchtern bis in die Fränkische Schweiz gefahren. Mit der Übergabe von und an Daniel war alles bestens."]
    let ratingStars: [Double] = [4, 5, 5]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.black.cgColor
        
        let imageUrl = storageAPI.getUserProfileImageUrl(uID: storageAPI.userID()) { (path) in
            let profileImgUrl = URL(string: path)
            self.imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(with: profileImgUrl)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
}

extension ExternProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ratingNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RatingsCollectionViewCell", for: indexPath) as! RatingsCollectionViewCell
        
        cell.userName.text = self.ratingNames[indexPath.row] + ":"
        cell.userRatingDescription.text = self.ratingDescriptions[indexPath.row]
        cell.userRatingStars.rating = self.ratingStars[indexPath.row]
        
        return cell
    }
}
