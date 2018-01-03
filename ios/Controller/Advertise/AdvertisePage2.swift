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
    var brandsPickerContent = ["AC Cars", "Alfa Romeo", "Alpina", "Alpine", "Alvis", "Amphicar", "Aston Martin", "Audi", "Austin-Healey", "Bentley", "BMW", "Borgward", "Bugatti", "Buick", "Cadillac", "Chevrolet", "Chrysler", "Citroën", "Dacia", "Daihatsu", "De Tomaso", "Delahaye", "DeLorean", "DKW", "Dodge", "Facel-Vega", "Ferrari", "Fiat", "Ford", "Honda", "Horch", "Hyundai", "Isuzu", "Iveco", "Jaguar", "Jeep", "Jensen", "Lada", "Lamborghini", "Lancia", "Land Rover", "Lincoln", "Lloyd", "Lotus", "Maserati", "Maybach", "Mazda", "Mercedes-Benz", "MG", "Mitsubishi", "Morgan", "Nissan", "NSU", "Opel", "Peugeot", "Piaggio", "Porsche","Reliant", "Renault", "Rolls-Royce", "Rover", "Saab", "Sachsenring", "Seat","Škoda", "Subaru",  "Sunbeam", "Suzuki","Toyota", "Triumph", "TVR", "Volvo", "VW", "Wartburg"]
    var seatsPickerContent = ["1", "2", "3", "4", "5", "6", "7", "8", "more"]
    var fuelPickerContent = ["gas", "diesel", "electric", "hybrid", "other"]
    var gearPickerContent = ["shift", "automatic", "semi-automatic"]
    var vehicleTypeContent = ["Compact", "Convertible", "Coupé", "Estate", "Limousine", "Minivan", "SUV", "Other Car"]
    
    var seatsPickerIcons = [UIImage(named:"1"), UIImage(named:"2"), UIImage(named:"3"), UIImage(named:"4"), UIImage(named:"5"), UIImage(named:"6"), UIImage(named:"7"), UIImage(named:"8"), UIImage(named:"9")]
    var fuelPickerIcons = [UIImage(named:"gas"), UIImage(named:"diesel"), UIImage(named:"electric"), UIImage(named:"hybrid"), UIImage(named:"other")]
    var gearPickerIcons = [UIImage(named:"manual"), UIImage(named:"automatic"), UIImage(named:"semi-automatic")]
    var vehicleTypeIcons = [UIImage(named:"Compact"), UIImage(named:"Convertible"), UIImage(named:"Coupé"), UIImage(named:"Estate"), UIImage(named:"Limousine"), UIImage(named:"Minivan"), UIImage(named:"SUV"), UIImage(named:"Other Car")]


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
        var countrows : Int = brandsPickerContent.count
        if (pickerView == seatsPicker) {
            countrows = self.seatsPickerContent.count
        } else if (pickerView == fuelPicker) {
            countrows = self.fuelPickerContent.count
        } else if (pickerView == gearPicker) {
            countrows = self.gearPickerContent.count
        } else if (pickerView == vehicleTypePicker) {
            countrows = self.vehicleTypeContent.count
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
            let title: String = brandsPickerContent[row]
            titleView.text = title
            let image = UIImage(named:title)
            imageView.image = image
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == seatsPicker){
            titleView.text = seatsPickerContent[row]
            imageView.image = seatsPickerIcons[row]
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == fuelPicker){
            titleView.text = fuelPickerContent[row]
            imageView.image = fuelPickerIcons[row]
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == gearPicker){
            titleView.text = gearPickerContent[row]
            imageView.image = gearPickerIcons[row]
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        } else if (pickerView == vehicleTypePicker){
            titleView.text = vehicleTypeContent[row]
            imageView.image = vehicleTypeIcons[row]
            view.addSubview(imageView)
            view.addSubview(titleView)
            return view
        }
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == brandPicker) {
            selectedBrand = self.brandsPickerContent[row]
            self.brandInput.text = selectedBrand
            self.brandPicker.isHidden = true
        } else if (pickerView == seatsPicker){
            selectedSeats = self.seatsPickerContent[row]
            self.seatsInput.text = selectedSeats
            self.seatsPicker.isHidden = true
        } else if (pickerView == fuelPicker){
            selectedFuel = self.fuelPickerContent[row]
            self.fuelInput.text = selectedFuel
            self.fuelPicker.isHidden = true
        } else if (pickerView == gearPicker){
            selectedGear = self.gearPickerContent[row]
            self.gearInput.text = selectedGear
            self.gearPicker.isHidden = true
        } else if (pickerView == vehicleTypePicker){
            selectedVehicleType = self.vehicleTypeContent[row]
            self.vehicleTypeInput.text = selectedVehicleType
            self.vehicleTypePicker.isHidden = true
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

}
