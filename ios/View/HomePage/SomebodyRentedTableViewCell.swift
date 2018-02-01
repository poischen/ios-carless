//
//  SomebodyRentedTableViewCell.swift
//  ios
//
//  Created by Konrad Fischer on 24.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import ScalingCarousel

class SomebodyRentedTableViewCell: ScalingCarouselCell {
    
    static let identifier = "SomebodyRentedTableViewCell"

    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var profileImage: RoundImage!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var offeringButton: PurpleButton!
    @IBOutlet weak var priceLabel: UILabel!
    
    var delegate: RatingProtocol?
    
    var event: RentingEvent? {
        didSet {
            guard let event = event as? SomebodyRented else {
                return
            }
            // setting labels'/buttons' texts
            actionLabel.text = "You let " + event.brand.name + " " + event.offering.type + " to " + event.coUser.name
            offeringButton.setTitle("about the car", for: .normal)
            startDateLabel.text = DateHelper.dateToString(date: event.renting.startDate)
            endDateLabel.text = DateHelper.dateToString(date: event.renting.startDate)
            priceLabel.text = "\(event.offering.basePrice)" + " €"
            if (event.isRateable) {
                // renting is rateable -> show rating button
                rateButton.isHidden = false
            } else {
                rateButton.isHidden = true
            }
        }
    }
    
    @IBAction func userButtonClicked(_ sender: Any) {
        guard let currentDelegate = delegate,
            let currentEvent = event as? SomebodyRented else {
                return
        }
        currentDelegate.goToProfile(user: currentEvent.userThatRented)
    }
    
    @IBAction func rateButtonClicked(_ sender: Any) {
        guard let currentDelegate = delegate,
            let currentEvent = event as? SomebodyRented else {
                return
        }
        currentDelegate.rateLessee(renting: currentEvent.renting, lesseeUser: currentEvent.userThatRented)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

  /*  override func setSelected(_ selected: Bool, animated: Bool) {
     super.isSelected(selected, animated: animated)
    }
*/
}
