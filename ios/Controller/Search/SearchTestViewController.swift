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

    @IBOutlet weak var collectionView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()

        // Do any additional setup after loading the view.
    }
    
    func setupCalendarView() {
        // setup calendar spacing
        collectionView.minimumLineSpacing = 0
        collectionView.minimumInteritemSpacing = 0
        
        // initialise month and year labels
        collectionView.visibleDates({visibleDates in
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
        handleCellBackground(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellBackground(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellBackground(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarLabels(from: visibleDates)
    }
}


