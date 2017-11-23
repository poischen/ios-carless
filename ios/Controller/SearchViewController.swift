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
    
    let occupantNumbers = ["1 person","2 persons","3 persons","4 persons","5 persons","6 persons","7 persons","8 persons"]
    let searchModel:SearchModel = SearchModel()
    
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
        return occupantNumbers[row]
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
        print(place.attributions)
        for test in place.addressComponents! {
            print(test.name)
        }
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
    
    func filterFunc (offering: Offering) -> Bool {
        return offering.seats > 4
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToSearchResults") { // TODO: check for something useful here
            // next screen: search results
            if let searchResultsViewController = segue.destination as? CarTableViewController {
                self.searchModel.getFilteredOfferings(filterFunctions: [filterFunc], completion: searchResultsViewController.receiveOfferings)
            }
        }
    }
}


