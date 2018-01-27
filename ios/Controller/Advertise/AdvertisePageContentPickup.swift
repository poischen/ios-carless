//
//  AdvertisePage5.swift
//  ios
//
//  Created by admin on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

/*
 * advertise rental picpup/return details
 */

import UIKit
import MapKit
import GooglePlacePicker

class AdvertisePageContentPickup: UIViewController {
    
    var pageViewController: AdvertisePagesVC!
    let storageAPI = StorageAPI.shared

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pickUpPicker: UIDatePicker!
    @IBOutlet weak var returnPicker: UIDatePicker!
    
    
    let locationManager = CLLocationManager()
    var searchController: UISearchController!
    var annotation: MKAnnotation!
    var localSearchRequest: MKLocalSearchRequest!
    var localSearch: MKLocalSearch!
    var localSearchResponse: MKLocalSearchResponse!
    var error: NSError!
    var pointAnnotation: MKPointAnnotation!
    var pinAnnotationView: MKPinAnnotationView!
    
    var selectedCity: String?
    var selectedLattitude: String?
    var selectedLongitude: String?
    var selectedGear: String?
    var selectedPickUpTime: String?
    var selectedReturnTime: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController = self.parent as! AdvertisePagesVC
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        searchBar.delegate = self
        
        pickUpPicker.date = Filter.dateToNext30(date: Date())
        returnPicker.date = Filter.dateToNext30(date: Date() + 1800)
        pickUpPicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        returnPicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        cacheTimes(picker: pickUpPicker)
        cacheTimes(picker: returnPicker)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func datePickerChanged(picker: UIDatePicker) {
        cacheTimes(picker: picker)
    }
    
    func cacheTimes(picker: UIDatePicker){
        let time: Date = picker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: time)
        if(picker == self.pickUpPicker) {
            pageViewController.advertiseHelper.pickupTime = timeString
        } else {
            pageViewController.advertiseHelper.returnTime = timeString
        }

    }
}

extension AdvertisePageContentPickup : UISearchBarDelegate, GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let searchText: String = place.formattedAddress!
        searchBar.text = searchText
        viewController.dismiss(animated: true, completion: nil)
        
        //Store data
        selectedLattitude =  String (place.coordinate.latitude)
        let selectedLattitudeFloat = Float(selectedLattitude!)
        if (selectedLattitudeFloat != nil) {
            pageViewController.advertiseHelper.latitude = selectedLattitudeFloat
        }
        
        selectedLongitude =  String (place.coordinate.longitude)
        let selectedLongitudeFloat = Float(selectedLongitude!)
        if (selectedLongitudeFloat != nil) {
            pageViewController.advertiseHelper.longitude = selectedLongitudeFloat
        }
        
        for component in place.addressComponents! {            
            if component.type == "locality" {
                selectedCity = component.name
                pageViewController.advertiseHelper.location = selectedCity
            }
        }


        //show data
        searchBar.resignFirstResponder()
        if self.mapView.annotations.count != 0{
            annotation = self.mapView.annotations[0]
            self.mapView.removeAnnotation(annotation)
        }
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchText
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = self.searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            
            
            self.pinAnnotationView = MKPinAnnotationView(annotation: self.pointAnnotation, reuseIdentifier: nil)
            self.mapView.centerCoordinate = self.pointAnnotation.coordinate
            self.mapView.addAnnotation(self.pinAnnotationView.annotation!)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        let autocompleteController = GMSAutocompleteViewController()
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

    }
}


extension AdvertisePageContentPickup : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: (error)")
    }
}


/*extension AdvertisePageContentPickup: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pageViewController.advertise.timeContent.count;
    }
    
     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pageViewController.advertise.timeContent[row]
     }
    
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == pickUpPicker) {
            selectedPickUpTime = self.pageViewController.advertise.timeContent[row]
            self.pickUpTextView.text = selectedPickUpTime
            self.pickUpPicker.isHidden = true
        } else if (pickerView == returnPicker){
            selectedReturnTime = self.pageViewController.advertise.timeContent[row]
            self.returnTextView.text = selectedReturnTime
            self.returnPicker.isHidden = true
        }
    }
}

extension AdvertisePageContentPickup: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if (textField == self.pickUpTextView){
            pageViewController.advertiseHelper.pickupTime = pickUpTextView.text
        } else if (textField == self.returnTextView){
            pageViewController.advertiseHelper.returnTime = returnTextView.text
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == self.pickUpTextView){
            self.pickUpPicker.isHidden = false
        } else if (textField == self.returnTextView){
            self.returnPicker.isHidden = false
        }
    }
 
    
} */