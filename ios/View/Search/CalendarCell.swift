//
//  CalendarCell.swift
//  ios
//
//  Created by Konrad Fischer on 28.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation
import UIKit

protocol CalendarCell {
    var dateLabel: UILabel! {get set}
    var selectedView: UIView! {get set}
}
