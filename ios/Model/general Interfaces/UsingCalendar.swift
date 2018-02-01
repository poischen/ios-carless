//
//  UsingCalendar.swift
//  ios
//
//  Created by Konrad Fischer on 01.02.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation
import JTAppleCalendar

protocol UsingCalendar: class {
    var firstDate: Date? {get set}
    var lastDate: Date? {get set}
    var recursiveSelectionCall: Bool {get set}
    var recursiveDeselectionCall: Bool {get set}
    var calendarView: JTAppleCalendarView! {get set}
}
