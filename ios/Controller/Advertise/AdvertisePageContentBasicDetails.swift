//
//  AdvertisePage2.swift
//  ios
//
//  Created by admin on 27.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

/*
 * advertise vehicle attributes
 */

class AdvertisePageContentBasicDetails: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var pageViewController: AdvertisePagesVC!
    let storageAPI = StorageAPI.shared
    
    @IBOutlet weak var brandPicker: UIPickerView!
    @IBOutlet weak var vehicleTypePicker: UIPickerView!
    @IBOutlet weak var seatsPicker: UIPickerView!
    @IBOutlet weak var fuelPicker: UIPickerView!
    @IBOutlet weak var gearPicker: UIPickerView!
    
    @IBOutlet weak var brandInput: UITextField!
    @IBOutlet weak var vehicleTypeInput: UITextField!
    @IBOutlet weak var modelInput: UITextField!
    @IBOutlet weak var seatsInput: UITextField!
    @IBOutlet weak var fuelInput: UITextField!
    @IBOutlet weak var gearInput: UITextField!
    @IBOutlet weak var consumptionInput: UITextField!
    @IBOutlet weak var speedInput: UITextField!
    
    var selectedBrand: String?
    var selectedSeats: String?
    var selectedFuel: String?
    var selectedGear: String?
    var selectedVehicleType: String?
    
    var selectedConsumption: String?
    var selectedSpeed: String?
    var selectedModel: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController = self.parent as! AdvertisePagesVC
        modelInput.delegate = self
        consumptionInput.delegate = self
        speedInput.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var countrows : Int = pageViewController.advertise.brandsPickerContent.count
        if (pickerView == seatsPicker) {
            countrows = self.pageViewController.advertise.seatsPickerContent.count
        } else if (pickerView == fuelPicker) {
            countrows = self.pageViewController.advertise.fuelPickerContent.count
        } else if (pickerView == gearPicker) {
            countrows = self.pageViewController.advertise.gearPickerContent.count
        } else if (pickerView == vehicleTypePicker) {
            countrows = self.pageViewController.advertise.vehicleTypeContent.count
        }
        
        return countrows;
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 110, height: 60)))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 15), size: CGSize(width: 30, height: 30)))
        let titleView = UILabel(frame: CGRect(origin: CGPoint(x: 40, y: 15), size: CGSize(width: 105, height: 32)))
        if (pickerView == brandPicker) {
            let title: String = pageViewController.advertise.brandsPickerContent[row]
            titleView.text = title
            let image = UIImage(named:title)
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == seatsPicker){
            titleView.text = pageViewController.advertise.seatsPickerContent[row]
            imageView.image = pageViewController.advertise.seatsPickerIcons[row]
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == fuelPicker){
            titleView.text = pageViewController.advertise.fuelPickerContent[row]
            imageView.image = pageViewController.advertise.fuelPickerIcons[row]
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == gearPicker){
            titleView.text = pageViewController.advertise.gearPickerContent[row]
            imageView.image = pageViewController.advertise.gearPickerIcons[row]
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == vehicleTypePicker){
            titleView.text = pageViewController.advertise.vehicleTypeContent[row]
            imageView.image = pageViewController.advertise.vehicleTypeIcons[row]
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        }
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == brandPicker) {
            selectedBrand = self.pageViewController.advertise.brandsPickerContent[row]
            self.brandPicker.isHidden = true
            if let brand = selectedBrand {
                pageViewController.advertiseHelper.convertAndCacheOfferingData(input: brand, key: Offering.OFFERING_BRAND_ID_KEY, conversionType: Advertise.ADVERTISE_CONVERSION_BRANDS)
                self.brandInput.text = brand
            }
            
        } else if (pickerView == seatsPicker){
            selectedSeats = self.pageViewController.advertise.seatsPickerContent[row]
            self.seatsPicker.isHidden = true
            if let seats = selectedSeats {
                pageViewController.advertiseHelper.convertAndCacheOfferingData(input: seats, key: Offering.OFFERING_SEATS_KEY, conversionType: Advertise.ADVERTISE_CONVERSION_SEATS)
                self.seatsInput.text = seats
            }
            
        } else if (pickerView == fuelPicker){
            selectedFuel = self.pageViewController.advertise.fuelPickerContent[row]
            self.fuelPicker.isHidden = true
            if let fuel = selectedFuel {
                    pageViewController.advertiseHelper.convertAndCacheOfferingData(input: fuel, key: Offering.OFFERING_FUEL_ID_KEY, conversionType: Advertise.ADVERTISE_CONVERSION_FUELS)
                self.fuelInput.text = fuel
            }
            
        } else if (pickerView == gearPicker){
            selectedGear = self.pageViewController.advertise.gearPickerContent[row]
            self.gearPicker.isHidden = true
            if let gear = selectedGear {
                pageViewController.advertiseHelper.convertAndCacheOfferingData(input: gear, key: Offering.OFFERING_GEAR_ID_KEY, conversionType: Advertise.ADVERTISE_CONVERSION_GEARS)
                self.gearInput.text = gear
            }
            
        } else if (pickerView == vehicleTypePicker){
            selectedVehicleType = self.pageViewController.advertise.vehicleTypeContent[row]
            self.vehicleTypePicker.isHidden = true
            if let vehicleType = selectedVehicleType {
                pageViewController.advertiseHelper.convertAndCacheOfferingData(input: vehicleType, key: Offering.OFFERING_VEHICLE_TYPE_ID_KEY, conversionType: Advertise.ADVERTISE_CONVERSION_VEHICLETYPES)
                self.vehicleTypeInput.text = vehicleType
            }
            
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == self.brandInput){
            self.brandPicker.isHidden = false
        } else if (textField == self.seatsInput){
            self.seatsPicker.isHidden = false
        } else if (textField == self.fuelInput){
            self.fuelPicker.isHidden = false
        } else if (textField == self.gearInput){
            self.gearPicker.isHidden = false
        } else if (textField == self.vehicleTypeInput) {
            self.vehicleTypePicker.isHidden = false
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if (textField == self.consumptionInput){
            selectedConsumption = consumptionInput.text
            if let consumption = selectedConsumption {
                if let consumptionInt = Int(consumption) {
                        pageViewController.advertiseHelper.consumption = consumptionInt
                }

            }
            
        } else if (textField == self.speedInput){
            selectedSpeed = speedInput.text
            if let speed = selectedSpeed {
                if let speedInt = Int(speed) {
                    pageViewController.advertiseHelper.hp = speedInt
                }
            }
            
        } else if (textField == self.modelInput){
            selectedModel = modelInput.text
            if let model = selectedModel {
                pageViewController.advertiseHelper.type = model
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField == self.speedInput || textField == self.consumptionInput){
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
        } else if (textField == self.modelInput) {
            return true
        } else {
        return false
    }
        
    }
}
