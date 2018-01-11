//
//  AvailibilityAndBookingViewController.swift
//  ios
//
//  Created by admin on 11.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import JTAppleCalendar

class AvailibilityAndBookingViewController: UIViewController {
    
    var pageViewController: AdvertisePagesVC!
    let storageAPI = StorageAPI.shared
    var offer: Offering?
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthAndYear: UILabel!
    @IBOutlet weak var resultView: UILabel!
    @IBOutlet weak var reservationButton: UIButton!
    
    let formatter = DateFormatter()
    var firstDate:Date?
    var lastDate:Date?
    var recursiveSelectionCall = false
    var recursiveDeselectionCall = false
    let selectedColor = UIColor(hue: 0.9917, saturation: 0.67, brightness: 0.75, alpha: 1.0)
    let releasedColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 1.0)
    let notInMonthColor = UIColor(hue: 0.7306, saturation: 0.07, brightness: 0.43, alpha: 1.0)
    
    var dates2Check: [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (offer?.userUID != storageAPI.userID()) {
            self.navigationItem.title = "Check Availibility"
        } else {
            self.navigationItem.title = "Preview"
            //todo: löschen button
            //todo: bearbeiten button
        }
        
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
    
    func handleSelectionVisually(view: JTAppleCell?, cellState: CellState){
        print(cellState)
        guard let cell = view as? AvailibilityCalendarCell else {return}
        if cellState.dateBelongsTo == .thisMonth {
            if cellState.isSelected {
                print("selected")
                cell.dateLabel.textColor = selectedColor
                cell.availibility.isBlocked = false
            } else {
                print("released")
                cell.dateLabel.textColor = releasedColor
                cell.availibility.isBlocked = true
            }
        }
    }
    
    func handleMonthColors(view: JTAppleCell?, cellState: CellState){
        guard let cell = view as? AvailibilityCalendarCell else {return}
        
        if cellState.isSelected {
            cell.dateLabel.textColor = selectedColor
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

extension AvailibilityAndBookingViewController: JTAppleCalendarViewDelegate {
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
        dates2Check.append(date)
        guard let selectedDate = cell as? AvailibilityCalendarCell else {return}
        handleSelectionVisually(view: selectedDate, cellState: cellState)
        print("SELECT")
        print(dates2Check)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
            if dates2Check.count > 0 {
                if let index = dates2Check.index(of: date) {
                    dates2Check.remove(at: index)
                }
            }
        
        guard let releasedDate = cell as? AvailibilityCalendarCell else {return}
        handleSelectionVisually(view: releasedDate, cellState: cellState)
        
        if recursiveSelectionCall == false {
            if let currentFirstDate = firstDate {
                if lastDate != nil {
                    calendarView.deselectDates(from: currentFirstDate, to: currentFirstDate, triggerSelectionDelegate: true)
                    firstDate = date
                    lastDate = nil
                } else {
                    if (date < currentFirstDate){
                        recursiveDeselectionCall = true
                        calendarView.deselectDates(from: firstDate!, to: firstDate!, triggerSelectionDelegate: true)
                        recursiveDeselectionCall = false
                        firstDate = date
                        lastDate = nil
                    } else {
                        lastDate = date
                        //???????????
                        if (firstDate != lastDate) {
                            recursiveSelectionCall = true
                            calendarView.selectDates(from: currentFirstDate, to: date,  triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: true)
                            recursiveSelectionCall = false
                        }
                    }
                }
            } else {
                firstDate = date
            }
        }
        print("DESELECT")
        print(dates2Check)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupMonthYear(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        // this function ensures that when one date from the current date interval is deselected all others are too
        // -> deselecting one date from the current date interval is sufficient
        if recursiveDeselectionCall == true {
            // this is a reursive call -> only deselect cell and don't start a new recursive call
            return true
        } else {
            if let currentFistDate = firstDate, let currentLastDate = lastDate {
                // deselect current date interval
                recursiveDeselectionCall = true // prevent endless recursion
                calendarView.deselectDates(from: currentFistDate, to: currentLastDate, triggerSelectionDelegate: true)
                recursiveDeselectionCall = false
                // unset first date and last date
                firstDate = nil
                lastDate = nil
            }
            return false
        }
    }

}

extension AvailibilityAndBookingViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        // formatter.timeZone = Calendar.current.timeZone
        // formatter.locale = Calendar.current.locale
        
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
