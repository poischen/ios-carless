//
//  FilterViewController.swift
//  ios
//
//  Created by Konrad Fischer on 09.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let filterDisabledText = "Filter is disabled"
    let filterEnabledText = "Filter is enabled"
    
    @IBOutlet weak var maxPriceLabel: UILabel!
    @IBOutlet weak var maxPriceSlider: UISlider!
    @IBOutlet weak var maxConsumptionLabel: UILabel!
    @IBOutlet weak var maxConsumptionSlider: UISlider!
    @IBOutlet weak var minHorsepowerLabel: UILabel!
    @IBOutlet weak var minHorsepowerSlider: UISlider!
    
    @IBOutlet weak var pickExtraTable: UITableView!
    @IBOutlet weak var pickFuelTable: UITableView!
    @IBOutlet weak var pickBrandTable: UITableView!
    @IBOutlet weak var pickGearTable: UITableView!
    @IBOutlet weak var pickVehicleTypeTable: UITableView!

    @IBOutlet weak var gearFilterStatusLabel: UILabel!
    @IBOutlet weak var vehicleTypeFilterStatusLabel: UILabel!
    @IBOutlet weak var engineFilterStatusLabel: UILabel!
    @IBOutlet weak var featuresFilterStatusLabel: UILabel!
    @IBOutlet weak var brandsFilterStatusLabel: UILabel!
    
    // TODO: use optionals here?
    // TODO: use Map for this?
    var features:[Feature] = [Feature]()
    var vehicleTypes:[VehicleType] = [VehicleType]()
    var fuels:[Fuel] = [Fuel]()
    var brands:[Brand] = [Brand]()
    var gears:[Gear] = [Gear]()
    
    let notificationCenter: NotificationCenter = NotificationCenter.default
    let storageAPI: StorageAPI = StorageAPI.shared
    let searchModel: SearchModel = SearchModel()
    var searchFilter:Filter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: Does this belong in viewDidLoad?
        
        pickFuelTable.delegate = self
        pickFuelTable.dataSource = self
        pickExtraTable.delegate = self
        pickExtraTable.dataSource = self
        pickBrandTable.delegate = self
        pickBrandTable.dataSource = self
        pickGearTable.dataSource = self
        pickGearTable.delegate = self
        pickVehicleTypeTable.delegate = self
        pickVehicleTypeTable.dataSource = self
        
        // get data from DB, receiving functions also restore the view state from the filter object
        storageAPI.getFeatures(completion: self.receiveFeatures)
        storageAPI.getVehicleTypes(completion: self.receiveVehicleTypes)
        storageAPI.getBrands(completion: self.receiveBrands)
        storageAPI.getFuels(completion: self.receiveFuels)
        storageAPI.getGears(completion: self.receiveGears)
        
        // restore UI state when the filter view is opened again
        if let currentMaxPrice = self.searchFilter?.maxPrice {
            self.maxPriceSlider.setValue(Float(currentMaxPrice), animated: false)
            self.maxPriceLabel.text = String(currentMaxPrice) + "€"
        }
        if let currentMinHP = self.searchFilter?.minHP {
            self.minHorsepowerSlider.setValue(Float(currentMinHP), animated: false)
            self.minHorsepowerLabel.text = String(currentMinHP) + " hp"
        }
        if let maxConsumption = self.searchFilter?.maxConsumption {
            self.maxConsumptionSlider.setValue(Float(maxConsumption), animated: false)
            self.maxConsumptionLabel.text = String(maxConsumption) + " l/100km"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func maxPriceChanged(_ sender: Any) {
        maxPriceLabel.text = String(Int(maxPriceSlider.value)) + "€"
        if self.searchFilter != nil {
            self.searchFilter!.maxPrice = Int(self.maxPriceSlider.value)
        }
    }
    
    @IBAction func maxConsumptionChanged(_ sender: Any) {
        maxConsumptionLabel.text = String(Int(maxConsumptionSlider.value)) + " l/100km"
        if self.searchFilter != nil {
            self.searchFilter!.maxConsumption = Int(self.maxConsumptionSlider.value)
        }
    }
    
    @IBAction func minHorsepowerChanged(_ sender: Any) {
        minHorsepowerLabel.text = String(Int(minHorsepowerSlider.value)) + " hp"
        if self.searchFilter != nil {
            self.searchFilter!.minHP = Int(self.minHorsepowerSlider.value)
        }
    }

    
    func filterFunc(_ offering: Offering) -> Bool {
        return offering.seats > 4
    }
    
    @IBAction func applyFiltersClicked(_ sender: Any) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        
        switch tableView {
        case self.pickExtraTable:
            count = features.count
        case self.pickFuelTable:
            count = fuels.count
        case self.pickBrandTable:
            count = brands.count
        case self.pickGearTable:
            count = gears.count
        case self.pickVehicleTypeTable:
            count = vehicleTypes.count;
        default:
            count = nil
        }

        
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellContent:SelectableItem
        var cellIdentifier:String
        
        switch tableView {
        case self.pickExtraTable:
            cellIdentifier = "ExtraTableViewCell"
            cellContent = self.features[indexPath.row]
        case self.pickFuelTable:
            cellIdentifier = "EngineTableViewCell"
            cellContent = fuels[indexPath.row]
        case self.pickBrandTable:
            cellIdentifier = "BrandTableViewCell"
            cellContent = brands[indexPath.row]
        case self.pickGearTable:
            cellIdentifier = "GearTableViewCell"
            cellContent = gears[indexPath.row]
        default: // covers pickVehicleTypeTable
            // TODO: better way to provide an exhaustive switch here?
            cellIdentifier = "VehicleTypeTableViewCell"
            cellContent = vehicleTypes[indexPath.row]
        }
        
        let returnCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        returnCell.textLabel!.text = cellContent.name
        if (cellContent.isSelected){
            returnCell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            returnCell.accessoryType = UITableViewCellAccessoryType.none
        }
        returnCell.selectionStyle = UITableViewCellSelectionStyle.none
        return returnCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
            case self.pickExtraTable:
                var feature = self.features[indexPath.row]
                feature.toggleSelected()
                self.updateSelectedFeaturesInFilter()
            case self.pickFuelTable:
                var engine = self.fuels[indexPath.row]
                engine.toggleSelected()
                self.updateSelectedFuelsInFilter()
            case self.pickBrandTable:
                var brand = self.brands[indexPath.row]
                brand.toggleSelected()
                self.updateSelectedBrandsInFilter()
            case self.pickGearTable:
                var gear = self.gears[indexPath.row]
                gear.toggleSelected()
                self.updateSelectedGearsInFilter()
            case self.pickVehicleTypeTable:
                var carType:VehicleType = self.vehicleTypes[indexPath.row]
                carType.toggleSelected()
                self.updateSelectedVehicleTypesInFilter()
            default:
                return
        }
        tableView.reloadRows(at: [indexPath], with: .none) // reload rows to reflect new selected status (show checkmark)
    }
    
    func receiveFeatures(features: [Feature]) -> Void {
        self.features = features
        self.pickExtraTable.reloadData()

        if let selectedFeatureIDs = self.searchFilter?.featureIDs {
            for selectedFeatureID in selectedFeatureIDs {
                let featureWithSelectedID = self.features.filter{$0.id == selectedFeatureID}
                if featureWithSelectedID.count == 1 {
                    featureWithSelectedID[0].isSelected = true
                }
            }
        }
    }
    
    func receiveVehicleTypes(vehicleTypes: [VehicleType]) -> Void {
        self.vehicleTypes = vehicleTypes
        self.pickVehicleTypeTable.reloadData()
        
        if let selectedVehicleTypeIDs = self.searchFilter?.vehicleTypeIDs {
            for selectedVehicleTypeID in selectedVehicleTypeIDs {
                let vehicleTypeWithSelectedID = self.vehicleTypes.filter{$0.id == selectedVehicleTypeID}
                if vehicleTypeWithSelectedID.count == 1 {
                    vehicleTypeWithSelectedID[0].isSelected = true
                }
            }
        }
    }
    
    func receiveFuels(fuels: [Fuel]) -> Void {
        self.fuels = fuels
        self.pickFuelTable.reloadData()
        
        if let selectedFuelIDs = self.searchFilter?.fuelIDs {
            for selectedFuelID in selectedFuelIDs {
                let fuelWithSelectedID = self.fuels.filter{$0.id == selectedFuelID}
                if fuelWithSelectedID.count == 1 {
                    fuelWithSelectedID[0].isSelected = true
                }
            }
        }
    }
    
    func receiveBrands(brands: [Brand]) -> Void {
        self.brands = brands
        self.pickBrandTable.reloadData() // added because table cells seem to be not available at this point until the table is reloaded
        
        if let selectedBrandIDs = self.searchFilter?.brandIDs {
             for selectedBrandID in selectedBrandIDs {
                let brandWithSelectedID = self.brands.filter{$0.id == selectedBrandID}
                if brandWithSelectedID.count == 1 {
                    brandWithSelectedID[0].isSelected = true
                }
             }
        }
    }
    
    func receiveGears(gears: [Gear]) -> Void {
        self.gears = gears
        self.pickGearTable.reloadData()
        
        if let selectedGearIDs = self.searchFilter?.gearIDs {
            for selectedGearID in selectedGearIDs {
                let gearWithSelectedID = self.gears.filter{$0.id == selectedGearID}
                if gearWithSelectedID.count == 1 {
                    gearWithSelectedID[0].isSelected = true
                }
            }
        }
    }
    
    // TODO: Do these methods belong in the model (-> filter class)?
    
    func updateSelectedFeaturesInFilter(){
        if let currentSearchFilter = self.searchFilter {
            let selectedFeatures = self.features.filter{$0.isSelected}
            if (selectedFeatures.count == 0){
                // no features selected -> disable filter
                currentSearchFilter.featureIDs = nil
                self.featuresFilterStatusLabel.text = self.filterDisabledText
            } else {
                // features selected -> enable filter
                currentSearchFilter.featureIDs = selectedFeatures.map{$0.id}
                self.featuresFilterStatusLabel.text = self.filterEnabledText
            }
        }
    }
    
    func updateSelectedBrandsInFilter(){
        if self.searchFilter != nil {
            self.searchFilter!.brandIDs = self.brands.filter{$0.isSelected}.map{$0.id}
        }
    }
    
    func updateSelectedGearsInFilter(){
        if self.searchFilter != nil {
            self.searchFilter!.gearIDs = self.gears.filter{$0.isSelected}.map{$0.id}
        }
    }
    
    func updateSelectedVehicleTypesInFilter(){
        if self.searchFilter != nil {
            self.searchFilter!.vehicleTypeIDs = self.vehicleTypes.filter{$0.isSelected}.map{$0.id}
        }
    }
    
    func updateSelectedFuelsInFilter(){
        if self.searchFilter != nil {
            self.searchFilter!.fuelIDs = self.fuels.filter{$0.isSelected}.map{$0.id}
        }
    }
    
    // TODO: remove?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.searchFilter != nil {
            self.searchFilter?.maxConsumption = Int(self.maxConsumptionSlider.value)
            self.searchFilter?.minHP = Int(self.minHorsepowerSlider.value)
            self.searchFilter?.maxPrice = Int(self.maxPriceSlider.value)
            self.updateSelectedFeaturesInFilter()
            self.updateSelectedBrandsInFilter()
            self.updateSelectedGearsInFilter()
            self.updateSelectedVehicleTypesInFilter()
            self.updateSelectedFuelsInFilter()
        }
    }

}
