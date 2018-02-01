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
    
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var userProfileImage: RoundImage!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var offerButton: PurpleButton!
    
    var delegate: RatingProtocol?
    
    var event: RentingEvent? {
        didSet {
            guard let event = event as? YouRented else {
                return
            }
            // setting labels'/buttons' texts
            carNameLabel.text = event.brand.name + " " + event.offering.type
            startDateLabel.text = DateHelper.dateToString(date: event.renting.startDate)
            endDateLabel.text = DateHelper.dateToString(date: event.renting.startDate)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
/*    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
  */
}
