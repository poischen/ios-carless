//
//  UserRentingsTableViewCell.swift
//  ios
//
//  Created by Konrad Fischer on 14.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import ScalingCarousel

class YouRentedTableViewCell: ScalingCarouselCell {
    
    static let identifier = "YouRentedTableViewCell"
    
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var carImageView: RoundImage!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var profileButton: PurpleButton!
    @IBOutlet weak var priceLabel: UILabel!
    
    static let ACCEPTED_STATUS_MESSAGE = "Renting confirmed"
    static let PENDING_STATUS_MESSAGE = "Confirmation pending..."
    
    var delegate: RatingProtocol?
    
    var event: RentingEvent? {
        didSet {
            guard let event = event as? YouRented else {
                return
            }
            // setting labels'/buttons' texts
            actionLabel.text = "You rented " + event.brand.name + " " + event.offering.type + " from " + event.coUser.name
            profileButton.setTitle("about " + event.coUser.name, for: .normal)
            startDateLabel.text = DateHelper.dateToString(date: event.renting.startDate)
            endDateLabel.text = DateHelper.dateToString(date: event.renting.startDate)
            priceLabel.text = "\(event.offering.basePrice)" + " €"
            if (event.renting.confirmationStatus) {
                // renting is confirmed -> show message
                statusLabel.text = YouRentedTableViewCell.ACCEPTED_STATUS_MESSAGE
            } else {
                // renting is pending -> show message
                statusLabel.text = YouRentedTableViewCell.PENDING_STATUS_MESSAGE
            }
            if (event.isRateable) {
                // renting is rateable -> show rating button
                rateButton.isHidden = false
                statusLabel.isHidden = true
            } else {
                rateButton.isHidden = true
            }
            
            let carImage: UIImage = UIImage(named: "carplaceholder")!
            carImageView.maskCircle(anyImage: carImage)
            let carImgUrl = URL(string: (event.offering.pictureURL))
            carImageView.kf.setImage(with: carImgUrl)
            
            let carImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.offerPicTapped))
            self.carImageView.isUserInteractionEnabled = true
            self.carImageView.addGestureRecognizer(carImageGestureRecognizer)
        }
    }
    
    func offerPicTapped(){
        guard let currentDelegate = delegate,
            let currentEvent = event as? YouRented else {
                return
        }
        currentDelegate.goToOffer(offer: currentEvent.offering)
    }
    
    @IBAction func rateButtonTapped(_ sender: Any) {
        guard let currentDelegate = delegate,
            let currentEvent = event as? YouRented else {
                return
        }
        currentDelegate.rateLessor(renting: currentEvent.renting)
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        guard let currentDelegate = delegate,
            let currentEvent = event as? YouRented else {
                return
        }
        currentDelegate.goToProfile(user: currentEvent.coUser)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
