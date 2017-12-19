//
//  AdvertisePageContentVC1.swift
//  advertise
//
//  Created by admin on 30.11.17.
//  Copyright © 2017 ioscars. All rights reserved.
//

import UIKit

class AdvertisePageContentVC: UIViewController, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker?.delegate = self
        //picker?.dataSource = self
        
        setupFeaturesCollectionView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //Page 1: Vehicle Picture-----------------------------
    
    var picker: UIImagePickerController? = UIImagePickerController()
    
    @IBOutlet weak var carImageView: UIImageView!
    
    @IBAction func openGallery(_ sender: UIButton) {
        openGallery()
    }
    
    @IBAction func openCamera(_ sender: UIButton) {
        openCamera()
    }
    
    
    // Take Photo button click
    @IBAction func takePhoto(sender: AnyObject) {
        
    }
    
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker!.allowsEditing = false
            picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
            present(picker!, animated: true, completion: nil)
        }
    }
    
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker!.allowsEditing = false
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    private func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        carImageView.contentMode = .scaleAspectFit
        carImageView.image = chosenImage
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButt(sender: AnyObject) {
        let imageData = UIImageJPEGRepresentation(carImageView.image!, 0.6)
        let compressedJPGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
        
    }
    
    //Page 2: Vehicle Attributes--------------------------------------
    @IBOutlet weak var brandPicker: UIPickerView!
    @IBOutlet weak var seatsPicker: UIPickerView!
    @IBOutlet weak var fuelPicker: UIPickerView!
    @IBOutlet weak var gearPicker: UIPickerView!
    
    @IBOutlet weak var brandInput: UITextField!
    @IBOutlet weak var modelInput: UITextField!
    @IBOutlet weak var seatsInput: UITextField!
    @IBOutlet weak var fuelInput: UITextField!
    @IBOutlet weak var gearInput: UITextField!
    
    var selectedBrand: String = ""
    var selectedSeats: String = ""
    var selectedFuel: String = ""
    var selectedGear: String = ""
    
    //TODO: Use data from DB
    var brandsPickerContent = ["AC Cars", "Alfa Romeo", "Alpina", "Alpine", "Alvis", "Amphicar", "Aston Martin", "Audi", "Austin-Healey", "Bentley", "BMW", "Borgward", "Bugatti", "Buick", "Cadillac", "Chevrolet", "Chrysler", "Citroën", "Dacia", "Daihatsu", "De Tomaso", "Delahaye", "DeLorean", "DKW", "Dodge", "Facel-Vega", "Ferrari", "Fiat", "Ford", "Honda", "Horch", "Hyundai", "Isuzu", "Iveco", "Jaguar", "Jeep", "Jensen", "Lada", "Lamborghini", "Lancia", "Land Rover", "Lincoln", "Lloyd", "Lotus", "Maserati", "Maybach", "Mazda", "Mercedes-Benz", "MG", "Mitsubishi", "Morgan", "Nissan", "NSU", "Opel", "Peugeot", "Piaggio", "Porsche","Reliant", "Renault", "Rolls-Royce", "Rover", "Saab", "Sachsenring", "Seat","Škoda", "Subaru",  "Sunbeam", "Suzuki","Toyota", "Triumph", "TVR", "Volvo", "VW", "Wartburg"]
    var seatsPickerContent = ["1", "2", "3", "4", "5", "6", "7", "8", "more"]
    var fuelPickerContent = ["gas", "diesel", "electric", "hybrid", "other"]
    var gearPickerContent = ["shift", "automatic", "semi-automatic"]
    
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
        }
        
        return countrows;
    }
    
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
        }
        return ""
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
        } else if (pickerView == seatsPicker){
            selectedGear = self.gearPickerContent[row]
            self.gearInput.text = selectedGear
            self.gearPicker.isHidden = true
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
        }
        
    }
    
    //Page 3: Vehicle Features / Extras-----------------------------
    var featuresCollectionView: UICollectionView!
    
    //TODO: Use data from DB
    var featuresImages = [UIImage(named: "navigation"), UIImage(named: "cruise_controll"), UIImage(named: "seat_heater"), UIImage(named: "infant_seat"), UIImage(named: "AC"), UIImage(named: "park_assistant"), UIImage(named: "front-camera"), UIImage(named: "back-camera"), UIImage(named: "cd_radio_mp3"), UIImage(named: "pre-heating"), UIImage(named: "wifi"), UIImage(named: "start_stop")]
    
    func setupFeaturesCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        featuresCollectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        featuresCollectionView.register(FeaturesCollectionViewCell.self, forCellWithReuseIdentifier: "featureCell")
        
        featuresCollectionView.backgroundColor = UIColor.white
        featuresCollectionView.delegate = self
        featuresCollectionView.dataSource = self
        
        view.addSubview(featuresCollectionView)
        
    }
    
    
    //TODO Interaction with cell
    //TODO Cellstyle
    //TODO CellView in PageView
    
    //Page 7: publish--------------------------------------
    @IBOutlet weak var publishButton: UIButton!
    
    @IBAction func öublishButtonTest(_ sender: Any) {
        let alertTest = UIAlertController(title: "Test", message: "This is a test", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
        alertTest.addAction(ok)
        present(alertTest, animated: true, completion: nil)
    }
    
    
}

extension AdvertisePageContentVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featuresImages.count
    }
    
    //TODO
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = featuresCollectionView.dequeueReusableCell(withReuseIdentifier: "featureCell", for: indexPath) as! FeaturesCollectionViewCell
        cell.awakeFromNib()
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let featureCell = cell as! FeaturesCollectionViewCell
        featureCell.featureIconImageView.image = featuresImages[indexPath.row]
        featureCell.featureLabel.text = "Test"
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: (view.frame.width/4), height: 200)
    }
}
