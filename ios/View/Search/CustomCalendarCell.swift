//
//  CustomCell.swift
//  ios
//
//  Created by Konrad Fischer on 03.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CustomCalendarCell: JTAppleCell, CalendarCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var selectedView: UIView!
}
