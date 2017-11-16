//
//  EngineTableViewCell.swift
//  ios
//
//  Created by Konrad Fischer on 16.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class EngineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var engineNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
