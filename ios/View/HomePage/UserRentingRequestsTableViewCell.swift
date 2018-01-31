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
    
    
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var ratingScoreLabel: UILabel!
    @IBOutlet weak var numberOfRatingsLabel: UILabel!
    
    var showedRenting: Renting?
    var delegate: RequestProcessingProtocol?
    var rentingUser: User?
    var somebodyRented: SomebodyRented? {
        didSet {
            guard let currentSomebodyRented = somebodyRented else {
                return
            }
            // setting labels'/buttons' texts
            usernameButton.setTitle(currentSomebodyRented.userThatRented.name, for: .normal)
            ratingScoreLabel.text = String(currentSomebodyRented.userThatRented.rating)
            carNameLabel.text = currentSomebodyRented.brand.name + " " + currentSomebodyRented.offering.type
            numberOfRatingsLabel.text = "(\(currentSomebodyRented.userThatRented.numberOfRatings) ratings)"
            // setting data necessary for using the buttons in the cell as gateway to other views
            showedRenting = currentSomebodyRented.renting
            rentingUser = currentSomebodyRented.userThatRented
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

/*    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
  */
    @IBAction func acceptButtonTapped(_ sender: Any) {
        guard let currentDelegate = delegate,
            let currentRenting = showedRenting else {
                return
        }
        currentDelegate.acceptRequest(renting: currentRenting)
    }
    
    @IBAction func usernameButtonTapped(_ sender: Any) {
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
