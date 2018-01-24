//
//  AdvertisePage4.swift
//  ios
//
//  Created by admin on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

/*
 * advertise rental availibility
 */

import UIKit
import JTAppleCalendar

class AdvertisePageConentAvailibilityCalendar: UIViewController {

    var pageViewController: AdvertisePagesVC!
    let storageAPI = StorageAPI.shared
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthAndYear: UILabel!
    @IBOutlet weak var priceTextView: UITextField!
    
    let formatter = DateFormatter()
    
    let notInMonthColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = self.parent as! AdvertisePagesVC
        
        priceTextView.delegate = self
        
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates { visibleDates in
            self.setupMonthYear(from: visibleDates)
        }
        
        calendarView.allowsMultipleSelection = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
  func handleSelection(view: JTAppleCell?, cellState: CellState){
    print("handleSelection")
    print(cellState)
        guard let cell = view as? AvailibilityCalendarCell else {return}
    if cellState.dateBelongsTo == .thisMonth {
        if cellState.isSelected {
            cell.cellSelectionFeedback.isHidden = false
            cell.availibility.isBlocked = false
        } else {
            print("released")
            cell.cellSelectionFeedback.isHidden = true
            cell.availibility.isBlocked = true
        }
    }
}
    
    func handleMonthColors(view: JTAppleCell?, cellState: CellState){
        guard let cell = view as? AvailibilityCalendarCell else {return}
        
        if cellState.isSelected {
            cell.cellSelectionFeedback.isHidden = false
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                cell.cellSelectionFeedback.isHidden = true
            } else {
            cell.dateLabel.textColor = notInMonthColor
            }
        }
    }
    
    func setupMonthYear(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "MMMM yy"
        monthAndYear.text = formatter.string(from: date)
    }
}

extension AdvertisePageConentAvailibilityCalendar: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let myCustomCell = cell as! AvailibilityCalendarCell
        let availibility = Availibility(date: date)
        myCustomCell.availibility = availibility
        myCustomCell.dateLabel.text = cellState.text
        handleMonthColors(view: myCustomCell, cellState: cellState)
    }
    
    

    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "availibilityCalendarCell", for: indexPath) as! AvailibilityCalendarCell
        self.calendar(calendar, willDisplay: myCustomCell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return myCustomCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        pageViewController.advertiseHelper.blockedDates.append(date)
        print(pageViewController.advertiseHelper.blockedDates)
        
        guard let blockedDate = cell as? AvailibilityCalendarCell else {return}
        handleSelection(view: blockedDate, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        pageViewController.advertiseHelper.releaseDate(date: date)
        
        guard let releasedDate = cell as? AvailibilityCalendarCell else {return}
        handleSelection(view: releasedDate, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupMonthYear(from: visibleDates)
    }
    
}

extension AdvertisePageConentAvailibilityCalendar: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let endDate = Date() + 31104000 // one year from now
        let parameters = ConfigurationParameters(
            startDate: Date(),
            endDate: endDate,
            numberOfRows: 6,
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .monday
        )
        return parameters
    }
}

extension AdvertisePageConentAvailibilityCalendar: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        let priceInt = Int(textField.text!)!
        pageViewController.advertiseHelper.basePrice = priceInt
    }
}
