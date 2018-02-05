//
//  UserRentingRequestsTableViewCell.swift
//  ios
//
//  Created by Konrad Fischer on 14.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import ScalingCarousel

class UserRentingRequestsTableViewCell: ScalingCarouselCell {
    
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet var requestorUserImage: UIImageView!
    @IBOutlet var startDateLabel: UILabel!
    @IBOutlet var endDateLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    var showedRenting: Renting?
    var delegate: RequestProcessingProtocol?
    var rentingUser: User?
    var somebodyRented: SomebodyRented? {
        didSet {
            guard let currentSomebodyRented = somebodyRented else {
                return
            }
            //setting ui data
            carNameLabel.text = (currentSomebodyRented.userThatRented.name + " wants to rent " + currentSomebodyRented.brand.name + " " + currentSomebodyRented.offering.type)
            
            let userImage: UIImage = UIImage(named: "ProfilePic")!
            requestorUserImage.maskCircle(anyImage: userImage)
            let userImgUrl = URL(string: (currentSomebodyRented.userThatRented.profileImgUrl))
            requestorUserImage.kf.setImage(with: userImgUrl)
            
            let profileImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserRentingRequestsTableViewCell.profilePicTapped))
            self.requestorUserImage.isUserInteractionEnabled = true
            self.requestorUserImage.addGestureRecognizer(profileImageGestureRecognizer)
            
            startDateLabel.text = DateHelper.dateToString(date: currentSomebodyRented.renting.startDate)
            endDateLabel.text = DateHelper.dateToString(date: currentSomebodyRented.renting.endDate)
            
            priceLabel.text = "\(currentSomebodyRented.renting.rentingPrice)" + " €"
            
            // setting data necessary for using the buttons in the cell as gateway to other views
            showedRenting = currentSomebodyRented.renting
            rentingUser = currentSomebodyRented.userThatRented
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func acceptButtonTapped(_ sender: Any) {
        guard let currentDelegate = delegate,
            let currentRenting = showedRenting else {
                return
        }
        currentDelegate.acceptRequest(renting: currentRenting)
    }
    
    func profilePicTapped() {
        print("TAPPED")
        guard let currentDelegate = delegate,
            let currentUser = rentingUser else {
                return
        }
        currentDelegate.goToProfile(user: currentUser)
    }
    
    @IBAction func denyButtonTapped(_ sender: Any) {
        guard let currentDelegate = delegate,
            let currentRenting = showedRenting else {
                return
        }
        currentDelegate.denyRequest(renting: currentRenting)
    }
}
