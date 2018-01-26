//
//  UserRentingsTableViewCell.swift
//  ios
//
//  Created by Konrad Fischer on 14.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit

class YouRentedTableViewCell: UITableViewCell {
    
    static let identifier = "YouRentedTableViewCell"

    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    
    static let ACCEPTED_STATUS_MESSAGE = "confirmed"
    static let PENDING_STATUS_MESSAGE = "pending"
    
    var delegate: RatingProtocol?
    
    var event: RentingEvent? {
        didSet {
            guard let event = event as? YouRented else {
                return
            }
            carNameLabel.text = event.brand.name + " " + event.offering.type
            startDateLabel.text = DateHelper.dateToString(date: event.renting.startDate)
            endDateLabel.text = DateHelper.dateToString(date: event.renting.startDate)
            if (event.renting.confirmationStatus) {
                // renting is confirmed
                statusLabel.text = YouRentedTableViewCell.ACCEPTED_STATUS_MESSAGE
            } else {
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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
