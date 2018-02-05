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

class SearchViewController: UIViewController, UsingCalendar {
    
    // UI components for the calendar
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    
    // other UI components
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var pickupTimePicker: UIDatePicker!
    @IBOutlet weak var returnTimePicker: UIDatePicker!
    @IBOutlet weak var occupantsPicker: UIPickerView!
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
    
    let CELL_IDENTIFIER = "SearchCalendarCell"
    let SEARCH_RESULTS_SEQUE_IDENTIFIER = "showSearchResultsNew"
    
    private var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        setupCalendarView()
        calendarView.allowsMultipleSelection  = true
        occupantsPicker.dataSource = self
        occupantsPicker.delegate = self
        
        pickupTimePicker.date = DateHelper.dateToNext30(date: Date()) // "round" time to next XX:00 or XX:30 time
        returnTimePicker.date = DateHelper.dateToNext30(date: Date() + 1800) // adding half an hour to the rounded time
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
            let desiredFirstDate = DateHelper.mergeDates(dayDate: currentFirstDate, hoursMinutesDate: pickupTimePicker.date)
            var desiredLastDate: Date
            if let currentLastDate = lastDate {
                // last date set -> user didn't select a one day interval -> merge calendar dates with pickup and return time
                desiredLastDate = DateHelper.mergeDates(dayDate: currentLastDate, hoursMinutesDate: returnTimePicker.date)
            } else {
                // no last date set -> user picker one day interval -> merge calendar dates with pickup and return time
                desiredLastDate = DateHelper.mergeDates(dayDate: currentFirstDate, hoursMinutesDate: returnTimePicker.date)
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
            performSegue(withIdentifier: SEARCH_RESULTS_SEQUE_IDENTIFIER, sender: nil)
        }
    }
    
    // change calendar cell text color depending on whether the cell belongs to the current month
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState){
        guard let currentCell = view as? SearchCalendarCell else {
            return
        }
        if cellState.dateBelongsTo == .thisMonth {
            currentCell.dateLabel.textColor = UIColor.black
        } else {
            currentCell.dateLabel.textColor = UIColor.darkGray
        }
    }
    
    // change calendar cell background according to the cell's selection status
    func handleSelection(cell: JTAppleCell?, cellState: CellState) {
        guard let currentCell = cell as? SearchCalendarCell else {
            return
        }
        if currentCell.isSelected {
            // cell is selected -> show special background and adapt font color
            currentCell.selectedView.isHidden = false
            currentCell.dateLabel.textColor = UIColor.white
        } else {
            // cell is not selected -> hide special background and adapt font color
            currentCell.selectedView.isHidden = true
            currentCell.dateLabel.textColor = UIColor.black
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
        if (segue.identifier == SEARCH_RESULTS_SEQUE_IDENTIFIER) {
            // next screen: search results
            guard let searchResultsViewController = segue.destination as? SearchResultsViewController,
                let currentDesiredRentingStart = desiredRentingStart,
                let currentDesiredRentingEnd = desiredRentingEnd,
                let currentPickedPlace = pickedPlace else {
                    return
            }
            // initialise filter with search UI elements values
            let newFilter:Filter = Filter(
                brandIDs: nil,
                maxConsumption: nil,
                fuelIDs: nil,
                gearIDs: nil,
                minHP: nil,
                maxPrice: nil,
                minSeats: occupantNumbers[occupantsPicker.selectedRow(inComponent: 0)],
                vehicleTypeIDs: nil,
                dateInterval: DateInterval(start: currentDesiredRentingStart, end: currentDesiredRentingEnd),
                featureIDs: nil,
                placePoint: CoordinatePoint(latitude: currentPickedPlace.coordinate.latitude, longitude: currentPickedPlace.coordinate.longitude)
            )
            // send filter to the next view controller by setting an attribute of it to the filter
            searchResultsViewController.searchFilter = newFilter
            searchResultsViewController.preselectedStartDate = currentDesiredRentingStart
            searchResultsViewController.preselectedEndDate = currentDesiredRentingEnd
        }
    }
    
}

extension SearchViewController: JTAppleCalendarViewDataSource{
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

extension SearchViewController: JTAppleCalendarViewDelegate{
    // sets up a cell before it's displayed
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        if let currentCell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CELL_IDENTIFIER, for: indexPath) as? SearchCalendarCell {
            currentCell.dateLabel.text = cellState.text
            updateCellVisuals(for: currentCell, withState: cellState)
            return currentCell
        } else {
            return JTAppleCell()
        }

    }
    
    // handle the selection of a cell, select other cells between first and last date if necessary
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleSelection(cell: cell, cellState: cellState) // always recolor cell ...
        CalendarLogic.didSelectDate(usingCalendar: self, selectedDate: date)
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
        return CalendarLogic.shouldDeselectDate(usingCalendar: self)
    }
}

extension SearchViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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

extension SearchViewController: GMSAutocompleteViewControllerDelegate, UISearchBarDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // user picked place -> safe picked place and hide place picker
        self.pickedPlace = place
        let searchText: String = place.formattedAddress!
        searchBar.text = searchText
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error in didFailAutocompleteWithError: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        // user canceled place picker -> hide it
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let autocompleteController = GMSAutocompleteViewController()
        let filter = GMSAutocompleteFilter()
        //filter.type = .address
        autocompleteController.autocompleteFilter = filter
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
}
