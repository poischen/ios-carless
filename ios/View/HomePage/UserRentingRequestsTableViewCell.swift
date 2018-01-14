//
//  UserRentingRequestsTableViewCell.swift
//  ios
//
//  Created by Konrad Fischer on 14.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit

class UserRentingRequestsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var carNameLabel: UILabel!
    @IBOutlet weak var ratingScoreLabel: UILabel!
    @IBOutlet weak var numberOfRatingsLabel: UILabel!
    
    var showedRenting: Renting?
    var delegate: RequestProcessingProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        guard let currentDelegate = delegate,
            let currentRenting = showedRenting else {
                return
        }
        currentDelegate.acceptRequest(renting: currentRenting)
    }
    
    @IBAction func denyButtonTapped(_ sender: Any) {
        guard let currentDelegate = delegate,
            let currentRenting = showedRenting else {
                return
        }
        currentDelegate.denyRequest(renting: currentRenting)
    }
}
