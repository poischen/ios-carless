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
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        nameLabel.text = place.formattedAddress
        print(place.formattedAddress)
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

