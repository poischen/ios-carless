//
//  SearchResultsTableViewCell.swift
//  ios
//
//  Created by Konrad Fischer on 24.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var mileageLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var fuelIcon: UIImageView!
    @IBOutlet weak var gearIcon: UIImageView!
    @IBOutlet weak var seatsIcon: UIImageView!
    @IBOutlet weak var priceButton: PurpleButton!
    @IBOutlet weak var brandIcon: UIImageView!
    
    var offering: Offering?
    var parent: SearchResultsViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func priceButtonSelected(_ sender: Any) {
        if let searchResultsVC = parent, let offer = offering {
            parent?.goToOffering(offer: offer)
        }
    }
}
