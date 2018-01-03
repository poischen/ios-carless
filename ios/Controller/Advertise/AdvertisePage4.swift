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

class AdvertisePage4: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthAndYear: UILabel!
    @IBOutlet weak var priceTextView: UITextField!
    
    let formatter = DateFormatter()
    
    let blockedColor = UIColor(hue: 0.9917, saturation: 0.21, brightness: 0.98, alpha: 1.0)
    let releasedColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 1.0)
    let notInMonthColor = UIColor(hue: 0.7306, saturation: 0.07, brightness: 0.43, alpha: 1.0)
    
    var basicPrice: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceTextView.delegate = self
        
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        calendarView.visibleDates { visibleDates in
            self.setupMonthYear(from: visibleDates)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
  func handleSelection(view: JTAppleCell?, cellState: CellState){
        guard let cell = view as? AvailibilityCalendarCell else {return}
    if cellState.dateBelongsTo == .thisMonth {
        if cellState.isSelected {
            cell.dateLabel.textColor = releasedColor
            cell.availibility.isBlocked = true
        } else {
            cell.dateLabel.textColor = blockedColor
            cell.availibility.isBlocked = false
        }
    }
}
    
    func handleMonthColors(view: JTAppleCell?, cellState: CellState){
        guard let cell = view as? AvailibilityCalendarCell else {return}
        
        if cellState.isSelected {
            cell.dateLabel.textColor = blockedColor
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                cell.dateLabel.textColor = releasedColor
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

extension AdvertisePage4: JTAppleCalendarViewDelegate {
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
        guard let blockedDate = cell as? AvailibilityCalendarCell else {return}
        handleSelection(view: blockedDate, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let releasedDate = cell as? AvailibilityCalendarCell else {return}
        handleSelection(view: releasedDate, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupMonthYear(from: visibleDates)
    }
    
}

extension AdvertisePage4: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let startYear =  components.year
        let endYear = startYear! + 1
        let month = components.month
        //let day = components.day
        
        let startDateString = (startYear?.description)! + " " + (month?.description)! + " 01"
        let endDateString = endYear.description + " " + (month?.description)! + " 01"
        let startDate = formatter.date(from: startDateString)!
        let endDate = formatter.date(from: endDateString)!
        print("configure calendar:  " + startDateString + " " + endDateString)
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek: .monday)
        return parameters
    }
}

extension AdvertisePage4: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
