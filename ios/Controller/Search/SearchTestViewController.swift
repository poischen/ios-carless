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

    // UI components for the calendar
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    // other UI components
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
    private let formatter = DateFormatter()
    private let currentCalendar = Calendar.current
    
    let occupantNumbers = Array(1...8)
    
    // search criteria
    var pickedPlace:GMSPlace?
    var desiredRentingStart:Date?
    var desiredRentingEnd:Date?
    
    // error messages
    private let ERROR_NO_PLACE_PICKED = "Please pick a location."
    private let ERROR_NO_FIRST_DATE_PICKED = "Please select a pickup date."
    private let ERROR_REVERSE_DATE_INTERVAL = "Please pick a return time after the pickup time."
    
    private var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        calendarView.allowsMultipleSelection  = true
        occupantsPicker.dataSource = self
        occupantsPicker.delegate = self
        
        pickupTimePicker.date = Filter.dateToNext30(date: Date()) // "round" time to next XX:00 or XX:30 time
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
        
        // initialise month and year labels after getting the visible dates
        calendarView.visibleDates({visibleDates in
            self.setupCalendarLabels(from: visibleDates)
        })
    }
    
    // show place picker when "pick place" button is clicked
    @IBAction func pickPlaceButtonClicked(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController()
        // create filter so that the picker only shows cities
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        autocompleteController.autocompleteFilter = filter
        autocompleteController.delegate = self
        // show place picker
        present(autocompleteController, animated: true, completion: nil)
    }
    
    // show error message in alert
    func showAlert(message: String){
        if let currentAlertController = alertController {
            // alert controller already created -> set message and show
            currentAlertController.message = message
            self.present(currentAlertController, animated: true, completion: nil)
        } else {
            // alert controller not created yet -> create and show
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        // user hasn't picked a place -> show error and don't proceed to the search results
        if pickedPlace == nil {
            showAlert(message: ERROR_NO_PLACE_PICKED)
            return
        }
        // user hasn't picked a first date in the calendar -> show error and don't proceed to the search results
        if firstDate == nil {
            // first date is not allowed to be nil, but last date is because it's not set when the user selects a one day interval
            showAlert(message: ERROR_NO_FIRST_DATE_PICKED)
            return
        } else {
            let currentFirstDate = firstDate!
            let desiredFirstDate = Filter.mergeDates(dayDate: currentFirstDate, hoursMinutesDate: pickupTimePicker.date)
            var desiredLastDate: Date
            if let currentLastDate = lastDate {
                // last date set -> user didn't select a one day interval -> merge calendar dates with pickup and return time
                desiredLastDate = Filter.mergeDates(dayDate: currentLastDate, hoursMinutesDate: returnTimePicker.date)
            } else {
                // no last date set -> user picker one day interval -> merge calendar dates with pickup and return time
                desiredLastDate = Filter.mergeDates(dayDate: currentFirstDate, hoursMinutesDate: returnTimePicker.date)
            }
            if desiredLastDate < desiredFirstDate {
                // user picked reverse date interval -> show error and don't proceed to the search results
                showAlert(message: ERROR_REVERSE_DATE_INTERVAL)
                return
            }
            // corrent date interval -> set desired renting start and desired renting end and ...
            desiredRentingStart = desiredFirstDate
            desiredRentingEnd = desiredLastDate
            // ... proceed to search results
            performSegue(withIdentifier: "showSearchResultsNew", sender: nil)
        }
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
        self.yearLabel.text = self.formatter.string(from: date)
        self.formatter.dateFormat = "MMMM"
        self.monthLabel.text = self.formatter.string(from: date)
    }
    
    // updates both the text color and the background of the cell according to it's status
    func updateCellVisuals(for cell: JTAppleCell, withState cellState: CellState){
        handleSelection(cell: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    // set the filter values in the next view controller (search results)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showSearchResultsNew") {
            // next screen: search results
            if let searchResultsViewController = segue.destination as? SearchResultsViewController, let currentDesiredRentingStart = desiredRentingStart, let currentDesiredRentingEnd = desiredRentingEnd {
                // create filter with the desired search criteria
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
                    dateInterval: DateInterval(start: currentDesiredRentingStart, end: currentDesiredRentingEnd),
                    featureIDs: nil
                )
                // send filter to the next view controller by setting an attribute of it to the filter
                searchResultsViewController.searchFilter = newFilter
            }
        }
    }

}

extension SearchTestViewController: JTAppleCalendarViewDataSource{
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

extension SearchTestViewController: JTAppleCalendarViewDelegate{
    // sets up a cell before it's displayed
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        // TODO: error handling
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        updateCellVisuals(for: cell, withState: cellState)
        return cell
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
    
    // date deselected -> update cell's background
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleSelection(cell: cell, cellState: cellState)
    }
    
    // change year and month labels if the user swipes to a new month
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarLabels(from: visibleDates)
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
        // user picked place -> safe picked place and hide place picker
        self.pickedPlace = place
        locationNameLabel.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error in didFailAutocompleteWithError: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // user canceled place picker -> hide it
        dismiss(animated: true, completion: nil)
    }
    
    
}


