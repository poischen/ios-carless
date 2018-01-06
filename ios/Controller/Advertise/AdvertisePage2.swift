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

class AdvertisePage2: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
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
    
    var selectedBrand: String = ""
    var selectedSeats: String = ""
    var selectedFuel: String = ""
    var selectedGear: String = ""
    var selectedVehicleType: String = ""
    
    //TODO: Use Values from DB
    /*var brandsPickerContent = ["AC Cars", "Alfa Romeo", "Alpina", "Alpine", "Alvis", "Amphicar", "Aston Martin", "Audi", "Austin-Healey", "Bentley", "BMW", "Borgward", "Bugatti", "Buick", "Cadillac", "Chevrolet", "Chrysler", "Citroën", "Dacia", "Daihatsu", "De Tomaso", "Delahaye", "DeLorean", "DKW", "Dodge", "Facel-Vega", "Ferrari", "Fiat", "Ford", "Honda", "Horch", "Hyundai", "Isuzu", "Iveco", "Jaguar", "Jeep", "Jensen", "Lada", "Lamborghini", "Lancia", "Land Rover", "Lincoln", "Lloyd", "Lotus", "Maserati", "Maybach", "Mazda", "Mercedes-Benz", "MG", "Mitsubishi", "Morgan", "Nissan", "NSU", "Opel", "Peugeot", "Piaggio", "Porsche","Reliant", "Renault", "Rolls-Royce", "Rover", "Saab", "Sachsenring", "Seat","Škoda", "Subaru",  "Sunbeam", "Suzuki","Toyota", "Triumph", "TVR", "Volvo", "VW", "Wartburg"]
    var seatsPickerContent = ["1", "2", "3", "4", "5", "6", "7", "8", "more"]
    var fuelPickerContent = ["gas", "diesel", "electric", "hybrid", "other"]
    var gearPickerContent = ["shift", "automatic", "semi-automatic"]
    var vehicleTypeContent = ["Compact", "Convertible", "Coupé", "Estate", "Limousine", "Minivan", "SUV", "Other Car"]
    
    var seatsPickerIcons = [UIImage(named:"1"), UIImage(named:"2"), UIImage(named:"3"), UIImage(named:"4"), UIImage(named:"5"), UIImage(named:"6"), UIImage(named:"7"), UIImage(named:"8"), UIImage(named:"9")]
    var fuelPickerIcons = [UIImage(named:"gas"), UIImage(named:"diesel"), UIImage(named:"electric"), UIImage(named:"hybrid"), UIImage(named:"other")]
    var gearPickerIcons = [UIImage(named:"manual"), UIImage(named:"automatic"), UIImage(named:"semi-automatic")]
    var vehicleTypeIcons = [UIImage(named:"Compact"), UIImage(named:"Convertible"), UIImage(named:"Coupé"), UIImage(named:"Estate"), UIImage(named:"Limousine"), UIImage(named:"Minivan"), UIImage(named:"SUV"), UIImage(named:"Other Car")]*/
    
    /*var brandsPickerContent: [String]?
    var seatsPickerContent: [String]?
    var fuelPickerContent: [String]?
    var gearPickerContent: [String]?
    var vehicleTypeContent: [String]?
    
    var seatsPickerIcons: [UIImage]?
    var fuelPickerIcons: [UIImage]?
    var gearPickerIcons: [UIImage]?
    var vehicleTypeIcons: [UIImage]?*/


    override func viewDidLoad() {
        super.viewDidLoad()
        pageViewController = self.parent as! AdvertisePagesVC
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        var countrows : Int = pageViewController.advertiseModel.brandsPickerContent.count
        if (pickerView == seatsPicker) {
            countrows = self.pageViewController.advertiseModel.seatsPickerContent.count
        } else if (pickerView == fuelPicker) {
            countrows = self.pageViewController.advertiseModel.fuelPickerContent.count
        } else if (pickerView == gearPicker) {
            countrows = self.pageViewController.advertiseModel.gearPickerContent.count
        } else if (pickerView == vehicleTypePicker) {
            countrows = self.pageViewController.advertiseModel.vehicleTypeContent.count
        }
        
        return countrows;
    }
    /*
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == brandPicker) {
            let titleRow = brandsPickerContent[row]
            return titleRow
        } else if (pickerView == seatsPicker){
            let titleRow = seatsPickerContent[row]
            return titleRow
        } else if (pickerView == fuelPicker){
            let titleRow = fuelPickerContent[row]
            return titleRow
        } else if (pickerView == gearPicker){
            let titleRow = gearPickerContent[row]
            return titleRow
        } else if (pickerView == vehicleTypePicker){
            let titleRow = vehicleTypeContent[row]
            return titleRow
        }
        return ""
    }*/
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 110, height: 60)))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 15), size: CGSize(width: 30, height: 30)))
        let titleView = UILabel(frame: CGRect(origin: CGPoint(x: 40, y: 15), size: CGSize(width: 105, height: 32)))
        if (pickerView == brandPicker) {
            let title: String = pageViewController.advertiseModel.brandsPickerContent[row]
            titleView.text = title
            let image = UIImage(named:title)
            imageView.image = image
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == seatsPicker){
            titleView.text = pageViewController.advertiseModel.seatsPickerContent[row]
            imageView.image = pageViewController.advertiseModel.seatsPickerIcons[row]
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == fuelPicker){
            titleView.text = pageViewController.advertiseModel.fuelPickerContent[row]
            imageView.image = pageViewController.advertiseModel.fuelPickerIcons[row]
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == gearPicker){
            titleView.text = pageViewController.advertiseModel.gearPickerContent[row]
            imageView.image = pageViewController.advertiseModel.gearPickerIcons[row]
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == vehicleTypePicker){
            titleView.text = pageViewController.advertiseModel.vehicleTypeContent[row]
            imageView.image = pageViewController.advertiseModel.vehicleTypeIcons[row]
//            imageView.image = pageViewController.advertiseModel.vehicleTypeIcons[row]
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        }
        return view
    }
    
    //TODO convert values to DB-IDs
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == brandPicker) {
            selectedBrand = self.pageViewController.advertiseModel.brandsPickerContent[row]
            self.brandInput.text = selectedBrand
            self.brandPicker.isHidden = true
            pageViewController.advertiseModel.updateDict(input: selectedBrand as AnyObject, key: Offering.OFFERING_BRAND_ID_KEY, needsConvertion: true, conversionType: Advertise.ADVERTISE_CONVERSION_BRANDS)
            
        } else if (pickerView == seatsPicker){
            selectedSeats = self.pageViewController.advertiseModel.seatsPickerContent[row]
            self.seatsInput.text = selectedSeats
            self.seatsPicker.isHidden = true
            
            /*var seats: AnyObject = (seatsInput.text as AnyObject)
            if (seats as! String == "more"){
                seats = 9 as AnyObject
            }*/
            pageViewController.advertiseModel.updateDict(input: selectedSeats as AnyObject, key: Offering.OFFERING_SEATS_KEY, needsConvertion: true, conversionType: Advertise.ADVERTISE_CONVERSION_SEATS)
            
        } else if (pickerView == fuelPicker){
            selectedFuel = self.pageViewController.advertiseModel.fuelPickerContent[row]
            self.fuelInput.text = selectedFuel
            self.fuelPicker.isHidden = true
            pageViewController.advertiseModel.updateDict(input: selectedFuel as AnyObject, key: Offering.OFFERING_FUEL_ID_KEY, needsConvertion: true, conversionType: Advertise.ADVERTISE_CONVERSION_FUELS)
            
        } else if (pickerView == gearPicker){
            selectedGear = self.pageViewController.advertiseModel.gearPickerContent[row]
            self.gearInput.text = selectedGear
            self.gearPicker.isHidden = true
            pageViewController.advertiseModel.updateDict(input: selectedGear as AnyObject, key: Offering.OFFERING_GEAR_ID_KEY, needsConvertion: true, conversionType: Advertise.ADVERTISE_CONVERSION_GEARS)
            
        } else if (pickerView == vehicleTypePicker){
            selectedVehicleType = self.pageViewController.advertiseModel.vehicleTypeContent[row]
            self.vehicleTypeInput.text = selectedVehicleType
            self.vehicleTypePicker.isHidden = true
            pageViewController.advertiseModel.updateDict(input: selectedVehicleType as AnyObject, key: Offering.OFFERING_VEHICLE_TYPE_ID_KEY, needsConvertion: true, conversionType: Advertise.ADVERTISE_CONVERSION_VEHICLETYPES)
            
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
            //let consumption: AnyObject = (consumptionInput.text as AnyObject)
            pageViewController.advertiseModel.updateDict(input: consumptionInput.text as AnyObject, key: Offering.OFFERING_CONSUMPTION_KEY, needsConvertion: false, conversionType: "none")
            
        } else if (textField == self.speedInput){
            //let speed: AnyObject = (speedInput.text as AnyObject)
            pageViewController.advertiseModel.updateDict(input: speedInput.text as AnyObject, key: Offering.OFFERING_HP_KEY, needsConvertion: false, conversionType: "none")
        } else if (textField == self.modelInput){
            //let model: AnyObject = (modelInput.text as AnyObject)
            pageViewController.advertiseModel.updateDict(input: modelInput.text as AnyObject, key: Offering.OFFERING_TYPE_KEY, needsConvertion: false, conversionType: "none")
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    { if (textField == self.consumptionInput || textField == self.speedInput){
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    } else {return true}
}
}
