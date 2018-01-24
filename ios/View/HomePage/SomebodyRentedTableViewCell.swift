//
//  SomebodyRentedTableViewCell.swift
//  ios
//
//  Created by Konrad Fischer on 24.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit

class SomebodyRentedTableViewCell: UITableViewCell {
    
    static let identifier = "SomebodyRentedTableViewCell"

    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var rentingStartLabel: UILabel!
    @IBOutlet weak var rentingEndLabel: UILabel!
    
    var delegate: RatingProtocol?
    
    var event: RentingEvent? {
        didSet {
            guard let event = event as? SomebodyRented else {
                return
            }
            carNameLabel.text = event.brand.name + " " + event.offering.type
            userButton.setTitle(event.userThatRented.name, for: .normal)
            rentingStartLabel.text = HomePageModel.dateToString(date: event.renting.startDate)
            rentingEndLabel.text = HomePageModel.dateToString(date: event.renting.startDate)
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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
