//
//  AvailibilityCalendarCell.swift
//  ios
//
//  Created by admin on 19.12.17.
//  Copyright © 2017 ioscars. All rights reserved.
//

import UIKit
import JTAppleCalendar

class AvailibilityCalendarCell: JTAppleCell, CalendarCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
    
    var availibility: Availibility!
    
}
