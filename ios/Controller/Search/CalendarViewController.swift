//
//  CalendarViewController.swift
//  ios
//
//  Created by Konrad Fischer on 27.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    
    var calendarViewNew: JTAppleCalendarView!
    var yearLabelNew: UILabel!
    var monthLabelNew: UILabel!
    
    // attributes for the calendar
    var firstDate:Date?
    var lastDate:Date?
    var recursiveSelectionCall = false
    var recursiveDeselectionCall = false
    private let formatter = DateFormatter()
    private let currentCalendar = Calendar.current

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initCalendar(calendarView: JTAppleCalendarView, yearLabel: UILabel, monthLabel: UILabel){
        monthLabelNew = monthLabel
        yearLabelNew = yearLabel
        calendarViewNew = calendarView
        
        setupCalendarView()
        calendarView.allowsMultipleSelection  = true
    }
    
    func setupCalendarView() {
        // setup calendar spacing
        calendarViewNew.minimumLineSpacing = 0
        calendarViewNew.minimumInteritemSpacing = 0
        
        // initialise month and year labels after getting the visible dates
        calendarViewNew.visibleDates({visibleDates in
            self.setupCalendarLabels(from: visibleDates)
        })
    }
    
    // change calendar cell text color depending on whether the cell belongs to the current month
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CustomCell else {
            return
        }
        if cellState.dateBelongsTo == .thisMonth {
            validCell.dateLabel.textColor = UIColor.black
        } else {
            validCell.dateLabel.textColor = UIColor.darkGray
        }
    }
    
    // change calendar cell background according to the cell's selection status
    func handleSelection(cell: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = cell as? CustomCell else {
            return
        }
        if myCustomCell.isSelected {
            // cell is selected -> show special background
            myCustomCell.selectedView.isHidden = false
        } else {
            // cell is not selected -> hide special background
            myCustomCell.selectedView.isHidden = true
        }
        
    }
    
    // sets up the labels for the current month and the current year the calendar shows
    func setupCalendarLabels(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        self.formatter.dateFormat = "yyyy"
        self.yearLabelNew.text = self.formatter.string(from: date)
        self.formatter.dateFormat = "MMMM"
        self.monthLabelNew.text = self.formatter.string(from: date)
    }
    
    // updates both the text color and the background of the cell according to it's status
    func updateCellVisuals(for cell: JTAppleCell, withState cellState: CellState){
        handleSelection(cell: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }

}

extension CalendarViewController: JTAppleCalendarViewDataSource{
    // method that JTAppleCalendar needs for initialisation, should always be similar to cellForItemAt
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        updateCellVisuals(for: cell, withState: cellState)
    }
    
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

extension CalendarViewController: JTAppleCalendarViewDelegate{
    // sets up a cell before it's displayed
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        if let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as? CustomCell {
            cell.dateLabel.text = cellState.text
            updateCellVisuals(for: cell, withState: cellState)
            return cell
        } else {
            return JTAppleCell()
        }
    }
    
    // handle the selection of a cell, select other cells between first and last date if necessary
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleSelection(cell: cell, cellState: cellState) // always recolor cell ...
        if recursiveSelectionCall == false { // ... but only examine whether a recursive call is necessary when this isn't already a recursive cell
            if let currentFirstDate = firstDate {
                // first date set
                if lastDate != nil {
                    // date range already set -> remove and set new first date
                    // deselecting one date is enough as the shouldDeselect function ensures that when one date from the current date interval is deselected all others are also
                    calendarViewNew.deselectDates(from: currentFirstDate, to: currentFirstDate, triggerSelectionDelegate: true)
                    firstDate = date
                    lastDate = nil
                } else {
                    // first date set, last date not set
                    if (date < currentFirstDate){
                        /* new date is before first date -> remove first date and set current date as new first date
                         first deselect current date interval
                         deselecting one date is enough as the shouldDeselect function ensures that when one date from the current date interval is deselected all others are also */
                        recursiveDeselectionCall = true
                        calendarViewNew.deselectDates(from: firstDate!, to: firstDate!, triggerSelectionDelegate: true)
                        recursiveDeselectionCall = false
                        firstDate = date // deselection resets first date -> set after deselection
                        lastDate = nil // for safety :)
                    } else {
                        // new date is on or after first date -> set last date
                        lastDate = date
                        if (firstDate != lastDate) {
                            // first date and last date are not on the same day -> select cells in between
                            recursiveSelectionCall = true // prevent endless recursion
                            calendarViewNew.selectDates(from: currentFirstDate, to: date,  triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: true)
                            recursiveSelectionCall = false
                        }
                    }
                }
            } else {
                // first date not set yet -> set first date
                firstDate = date
            }
        }
    }
    
    // date deselected -> update cell's background
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleSelection(cell: cell, cellState: cellState)
    }
    
    // change year and month labels if the user swipes to a new month
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarLabels(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        // prevent user from selecting dates in the past
        let now = Date()
        return date > now
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
                calendarViewNew.deselectDates(from: currentFistDate, to: currentLastDate, triggerSelectionDelegate: true)
                recursiveDeselectionCall = false
                // unset first date and last date
                firstDate = nil
                lastDate = nil
            }
            return false
        }
    }
}
