//
//  ViewController.swift
//  iOS Cars
//
//  Created by Konrad Fischer on 31.10.17.
//  Copyright © 2017 Konrad Fischer. All rights reserved.
//

// !! This class is deprecated, using SearchTestViewController now

import UIKit
import GooglePlacePicker
// import GoogleMaps

class SearchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,  GMSAutocompleteViewControllerDelegate {
    
    
    @IBOutlet weak var occupantsPicker: UIPickerView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var startTimeDatePicker: UIDatePicker!
    @IBOutlet weak var startTimeTimePicker: UIDatePicker!
    @IBOutlet weak var endTimeDatePicker: UIDatePicker!
    @IBOutlet weak var endTimeTimePicker: UIDatePicker!
    
    let occupantNumbers = Array(1...8)
    var pickedPlace:GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        occupantsPicker.dataSource = self
        occupantsPicker.delegate = self
        
        /*
        // only make dates in the future pickable
        startTimeDatePicker.minimumDate = Filter.dateToNext30(date: Date()) + 1800 // adding half an hour
        endTimeDatePicker.minimumDate = startTimeDatePicker.date + 86400 // adding one day
         */
        startTimeDatePicker.minimumDate = Date() + 86400 // adding one day
        endTimeDatePicker.minimumDate = Date() + 86400 // adding one day
        startTimeTimePicker.date = Filter.dateToNext30(date: Date())
        endTimeTimePicker.date = Filter.dateToNext30(date: Date() + 1800) // adding half an hour
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    @IBAction func pickPlace(_ sender: UIButton) {
        let autocompleteController = GMSAutocompleteViewController()
        let filter = GMSAutocompleteFilter()
        filter.type = .city
        autocompleteController.autocompleteFilter = filter
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {

        self.pickedPlace = place
        nameLabel.text = place.formattedAddress
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        // only proceed to the search results if the user has picked a place
        if let userPickedPlace = pickedPlace {
            performSegue(withIdentifier: "showSearchResults", sender: nil)
        } else {
            // show error message to remind the user to pick a place first
            let alertController = UIAlertController(title: "Error", message: "Please pick a location.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func startTimeChanged(_ sender: Any) {
        // prevent the user from creating reverse date intervals
        self.endTimeDatePicker.minimumDate = self.startTimeDatePicker.date
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showSearchResults") {
            let mergedStartDate = Filter.mergeDates(dayDate: startTimeDatePicker.date, hoursMinutesDate: startTimeTimePicker.date)
            let mergedEndDate = Filter.mergeDates(dayDate: endTimeDatePicker.date, hoursMinutesDate: endTimeTimePicker.date)
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
                
                print(startTimeDatePicker.date)
            }
        }
    }
    
}


