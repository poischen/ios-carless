//
//  ViewController.swift
//  iOS Cars
//
//  Created by Konrad Fischer on 31.10.17.
//  Copyright © 2017 Konrad Fischer. All rights reserved.
//

import UIKit
import GooglePlacePicker
// import GoogleMaps

class SearchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource,  GMSAutocompleteViewControllerDelegate {
    
    @IBOutlet weak var startTimePicker: UIDatePicker!
    @IBOutlet weak var endTimePicker: UIDatePicker!
    @IBOutlet weak var occupantsPicker: UIPickerView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    let occupantNumbers = Array(1...8)
    var pickedPlace:GMSPlace?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        occupantsPicker.dataSource = self
        occupantsPicker.delegate = self
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
        /* for test in place.addressComponents! {
            print(test.name)
        } */
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showSearchResults") {
            // next screen: search results
            if let searchResultsViewController = segue.destination as? SearchResultsViewController {
                let newFilter:Filter = Filter(
                    maxPrice: nil,
                    minSeats: occupantNumbers[occupantsPicker.selectedRow(inComponent: 0)],
                    city: pickedPlace!.addressComponents![0].name,
                    maxConsumption: nil,
                    minHP: nil,
                    gearshift: nil,
                    brands: nil,
                    engines: nil,
                    featureIDs: nil,
                    dateInterval: nil
                )
                searchResultsViewController.searchFilter = newFilter
            }
        }
    }
}


