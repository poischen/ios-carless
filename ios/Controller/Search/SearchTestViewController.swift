//
//  SearchTestViewController.swift
//  ios
//
//  Created by Konrad Fischer on 03.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import JTAppleCalendar
import GooglePlacePicker

class SearchTestViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var pickupTimePicker: UIDatePicker!
    @IBOutlet weak var returnTimePicker: UIDatePicker!
    @IBOutlet weak var occupantsPicker: UIPickerView!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var pickPlaceButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    // attributes for the calendar
    var firstDate:Date?
    var lastDate:Date?
    var recursiveSelectionCall = false
    var recursiveDeselectionCall = false
    let formatter = DateFormatter()
    let currentCalendar = Calendar.current
    
    let occupantNumbers = Array(1...8)
    var pickedPlace:GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        calendarView.allowsMultipleSelection  = true
        occupantsPicker.dataSource = self
        occupantsPicker.delegate = self
        
        pickupTimePicker.date = Filter.dateToNext30(date: Date())
        returnTimePicker.date = Filter.dateToNext30(date: Date() + 1800) // adding half an hour to the rounded time

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func pickPlaceButtonClicked(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        autocompleteController.autocompleteFilter = filter
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        // only proceed to the search results if the user has picked a place
        // TODO: also check for picked place here
        // TODO: check that pickup time isn't before return time
        if let userPickedPlace = pickedPlace {
            performSegue(withIdentifier: "showSearchResultsNew", sender: nil)
        } else {
            // show error message to remind the user to pick a place first
            let alertController = UIAlertController(title: "Error", message: "Please pick a location.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
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
        self.yearLabel.text = self.formatter.string(from: date)
        self.formatter.dateFormat = "MMMM"
        self.monthLabel.text = self.formatter.string(from: date)
    }
    
    func updateCellVisuals(for cell: JTAppleCell, withState cellState: CellState){
        handleSelection(cell: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showSearchResultsNew") {
            // TODO: handle errors here
            let mergedStartDate = Filter.setDatesHoursMinutes(originalDate: firstDate!, hoursMinutesDate: pickupTimePicker.date)
            let mergedEndDate = Filter.setDatesHoursMinutes(originalDate: lastDate!, hoursMinutesDate: returnTimePicker.date)
            // next screen: search results
            if let searchResultsViewController = segue.destination as? SearchResultsViewController {
                let newFilter:Filter = Filter(
                    brandIDs: nil,
                    maxConsumption: nil,
                    fuelIDs: nil,
                    gearIDs: nil,
                    minHP: nil,
                    location: pickedPlace!.addressComponents![0].name, // only use the city name for the search
                    maxPrice: nil,
                    minSeats: occupantNumbers[occupantsPicker.selectedRow(inComponent: 0)],
                    vehicleTypeIDs: nil,
                    dateInterval: DateInterval(start: mergedStartDate, end: mergedEndDate),
                    featureIDs: nil
                )
                searchResultsViewController.searchFilter = newFilter
            }
        }
    }

}

extension SearchTestViewController: JTAppleCalendarViewDataSource{
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        // TODO: error handling
        //handleCellBackground(view: cell, cellState: cellState)
        updateCellVisuals(for: cell, withState: cellState)
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
        updateCellVisuals(for: cell, withState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleSelection(cell: cell, cellState: cellState) // always recolor cell ...
        if recursiveSelectionCall == false { // ... but only examine whether a recursive call is necessary when this isn't already a recursive cell
            if let currentFirstDate = firstDate {
                // first date set
                if lastDate != nil {
                    // date range already set -> remove and set new first date
                    // deselecting one date is enough as the shouldDeselect function ensures that when one date from the current date interval is deselected all others are also
                    calendarView.deselectDates(from: currentFirstDate, to: currentFirstDate, triggerSelectionDelegate: true)
                    firstDate = date
                    lastDate = nil
                } else {
                    // first date set, last date not set
                    if (date < currentFirstDate){
                        /* new date is before first date -> remove first date and set current date as new first date
                        first deselect current date interval
                        deselecting one date is enough as the shouldDeselect function ensures that when one date from the current date interval is deselected all others are also */
                        recursiveDeselectionCall = true
                        calendarView.deselectDates(from: firstDate!, to: firstDate!, triggerSelectionDelegate: true)
                        recursiveDeselectionCall = false
                        firstDate = date // deselection resets first date -> set after deselection
                        lastDate = nil // for safety :)
                    } else {
                        // new date is on or after first date -> set last date
                        lastDate = date
                        if (firstDate != lastDate) {
                            // first date and last date are not on the same day -> select cells in between
                            recursiveSelectionCall = true // prevent endless recursion
                            calendarView.selectDates(from: currentFirstDate, to: date,  triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: true)
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
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleSelection(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarLabels(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        /* if cellState.dateBelongsTo == .thisMonth {
            return true
        } else {
            return false
        } */
        return true
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        // this function ensures that when one date from the current date interval is deselected all others are also
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

extension SearchTestViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return occupantNumbers.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(occupantNumbers[row])
    }
}

extension SearchTestViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        self.pickedPlace = place
        locationNameLabel.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}


