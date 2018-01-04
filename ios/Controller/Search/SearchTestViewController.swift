//
//  SearchTestViewController.swift
//  ios
//
//  Created by Konrad Fischer on 03.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import JTAppleCalendar

class SearchTestViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    
    var firstDate:Date?
    var lastDate:Date?
    var recursiveCall = false
    
    let formatter = DateFormatter()
    let currentCalendar = Calendar.current
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        calendarView.allowsMultipleSelection  = true
        //calendarView.rangeSelectionWillBeUsed = true

        // Do any additional setup after loading the view.
    }
    
    func setupCalendarView() {
        // setup calendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        // initialise month and year labels
        calendarView.visibleDates({visibleDates in
            self.setupCalendarLabels(from: visibleDates)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleCellBackground(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CustomCell else {
            return
        }
        if validCell.isSelected {
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
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
    
    func handleSelection(cell: JTAppleCell?, cellState: CellState) {
        guard let myCustomCell = cell as? CustomCell else {
            return
        }
        switch cellState.selectedPosition() {
        case .full, .left, .right, .middle:
            myCustomCell.selectedView.isHidden = false
        default:
            myCustomCell.selectedView.isHidden = true
        }
        
    }
    
    func setupCalendarLabels(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        self.formatter.dateFormat = "yyyy"
        self.year.text = self.formatter.string(from: date)
        self.formatter.dateFormat = "MMMM"
        self.month.text = self.formatter.string(from: date)
    }

}

extension SearchTestViewController: JTAppleCalendarViewDataSource{
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {

    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let endDate = Date() + 31104000 // add one year
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

extension SearchTestViewController: JTAppleCalendarViewDelegate{
    // display the cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        // TODO: error handling
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        //handleCellBackground(view: cell, cellState: cellState)
        handleSelection(cell: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleSelection(cell: cell, cellState: cellState)
        if recursiveCall == false {
            if firstDate != nil {
                // first date set
                if lastDate != nil {
                    // date range already set -> remove and set new first date
                    calendarView.deselectDates(from: firstDate!, to: lastDate!, triggerSelectionDelegate: true)
                    firstDate = date
                    lastDate = nil
                } else {
                    // first date set, last date not set -> set last date and select cells in between
                    lastDate = date
                    recursiveCall = true
                    calendarView.selectDates(from: firstDate!, to: date,  triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: true)
                    recursiveCall = false
                }
            } else {
                // first date not set yet -> set first date
                firstDate = date
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        //handleCellBackground(view: cell, cellState: cellState)
        handleSelection(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarLabels(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        /*if firstDate == nil {
            // first date not yet selected -> select it
            firstDate = date
            return true
        } else {
            // first date already selected
            if lastDate == nil {
                // last date not selected yet -> select it -> date range complete
                lastDate = date
                // also select all dates in between if the range consists of more than two days
                let dateAfterFirstDate = currentCalendar.date(byAdding: .day, value: 1, to: firstDate!)
                if (dateAfterFirstDate != lastDate){
                    let dateBeforeLastDate = currentCalendar.date(byAdding: .day, value: -1, to: lastDate!)
                    calendarView.selectDates(from: dateAfterFirstDate!, to: dateBeforeLastDate!, triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: true)
                }
                return true
            } else {
                // first date and last date are already selected -> reset selection and select new first date
                calendarView.deselectAllDates()
                lastDate = nil
                firstDate = date
                return true
            }
        }*/
        if cellState.dateBelongsTo == .thisMonth {
            return true
        } else {
            return false
        }
    }

}


