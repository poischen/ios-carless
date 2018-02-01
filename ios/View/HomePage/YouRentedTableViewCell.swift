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
    @IBOutlet weak var carImage: RoundImage!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var profileButton: PurpleButton!
    @IBOutlet weak var priceLabel: UILabel!
    
    static let ACCEPTED_STATUS_MESSAGE = "Renting confirmed"
    static let PENDING_STATUS_MESSAGE = "Waiting for confirmation..."
    
    var delegate: RatingProtocol?
    
    var event: RentingEvent? {
        didSet {
            guard let event = event as? YouRented else {
                return
            }
            // setting labels'/buttons' texts
            actionLabel.text = "You let " + event.brand.name + " " + event.offering.type + " to " + event.coUser.name
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
        }
    }
    
    @IBAction func rateButtonTapped(_ sender: Any) {
        guard let currentDelegate = delegate,
            let currentEvent = event as? YouRented else {
                return
        }
        currentDelegate.rateLessor(renting: currentEvent.renting)
    }
    
    @IBAction func offeringButtonTapped(_ sender: Any) {
        /*if let offer = self.offer, let eHomePageViewController = self.eHomePageViewController {
            eHomePageViewController.presentOfferView(offer: offer)
        }*/
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
/*    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
  */
}
