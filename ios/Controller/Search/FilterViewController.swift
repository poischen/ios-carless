//
//  FilterViewController.swift
//  ios
//
//  Created by Konrad Fischer on 09.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // text for the filter status labels
    let FILTER_DISABLED_TEXT = "Filter is disabled"
    let FILTER_ENABLED_TEXT = "Filter is enabled"
    
    // units for the slider filters
    let FILTER_UNIT_PRICE = "€"
    let FILTER_UNIT_CONSUMPTION = "l/100km"
    let FILTER_UNIT_HORSEPOWER = "hp"
    
    // outlets of sliders and their labels
    @IBOutlet weak var maxPriceLabel: UILabel!
    @IBOutlet weak var maxPriceSlider: UISlider!
    @IBOutlet weak var maxConsumptionLabel: UILabel!
    @IBOutlet weak var maxConsumptionSlider: UISlider!
    @IBOutlet weak var minHorsepowerLabel: UILabel!
    @IBOutlet weak var minHorsepowerSlider: UISlider!
    
    // outlets of table views
    @IBOutlet weak var pickExtraTable: UITableView!
    @IBOutlet weak var pickFuelTable: UITableView!
    @IBOutlet weak var pickBrandTable: UITableView!
    @IBOutlet weak var pickGearTable: UITableView!
    @IBOutlet weak var pickVehicleTypeTable: UITableView!
    
    // cell identifiers of the table views
    let PICK_EXTRA_TABLE_CELL_IDENTIFIER = "ExtraTableViewCell"
    let PICK_FUEL_TABLE_CELL_IDENTIFIER = "EngineTableViewCell"
    let PICK_BRAND_TABLE_CELL_IDENTIFIER = "BrandTableViewCell"
    let PICK_GEAR_TABLE_CELL_IDENTIFIER = "GearTableViewCell"
    let PICK_VEHICLE_TYPE_TABLE_CELL_IDENTIFIER = "VehicleTypeTableViewCell"



    // outlets of filter status labels of the table views
    @IBOutlet weak var gearFilterStatusLabel: UILabel!
    @IBOutlet weak var vehicleTypeFilterStatusLabel: UILabel!
    @IBOutlet weak var fuelFilterStatusLabel: UILabel!
    @IBOutlet weak var featuresFilterStatusLabel: UILabel!
    @IBOutlet weak var brandsFilterStatusLabel: UILabel!
    
    // arrays for the filters' elements
    var features:[Feature] = [Feature]()
    var vehicleTypes:[VehicleType] = [VehicleType]()
    var fuels:[Fuel] = [Fuel]()
    var brands:[Brand] = [Brand]()
    var gears:[Gear] = [Gear]()
    
    // references to DB and search model
    let storageAPI: StorageAPI = StorageAPI.shared
    var searchFilter:Filter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set this view controller as delegate and data source of all the table views it contains
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        // get filter items from DB, receiving functions also restore the view state from the filter object
        storageAPI.getFeatures(completion: self.receiveFeatures)
        storageAPI.getVehicleTypes(completion: self.receiveVehicleTypes)
        storageAPI.getBrands(completion: self.receiveBrands)
        storageAPI.getFuels(completion: self.receiveFuels)
        storageAPI.getGears(completion: self.receiveGears)
        
        // restore UI state from filter object when the filter view is opened again if the respective filters are set
        if let currentMaxPrice = self.searchFilter?.maxPrice {
            self.maxPriceSlider.setValue(Float(currentMaxPrice), animated: false) // restore slider state
            self.maxPriceLabel.text = String(currentMaxPrice) + " " + FILTER_UNIT_PRICE // restore label state to match slider state
        }
        if let currentMinHP = self.searchFilter?.minHP {
            self.minHorsepowerSlider.setValue(Float(currentMinHP), animated: false)
            self.minHorsepowerLabel.text = String(currentMinHP) + " " + FILTER_UNIT_HORSEPOWER
        }
        if let maxConsumption = self.searchFilter?.maxConsumption {
            self.maxConsumptionSlider.setValue(Float(maxConsumption), animated: false)
            self.maxConsumptionLabel.text = String(maxConsumption) + " " + FILTER_UNIT_CONSUMPTION
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func maxPriceChanged(_ sender: Any) {
        // update filter label and filter object (if available) if max price slider is moved
        maxPriceLabel.text = String(Int(maxPriceSlider.value)) + "€" // cast slider's value to int first to round
        if let currentSearchFilter = self.searchFilter {
            currentSearchFilter.maxPrice = Int(self.maxPriceSlider.value) // also round here
        }
    }
    
    @IBAction func maxConsumptionChanged(_ sender: Any) {
        // update filter label and filter object (if available) if max consumption slider is moved
        maxConsumptionLabel.text = String(Int(maxConsumptionSlider.value)) + " l/100km" // cast slider's value to int first to round for safety reasons
        if let currentSearchFilter = self.searchFilter {
            currentSearchFilter.maxConsumption = Int(self.maxConsumptionSlider.value) // also round here
        }
    }
    
    @IBAction func minHorsepowerChanged(_ sender: Any) {
        // update filter label and filter object (if available) if min horsepower slider is moved
        minHorsepowerLabel.text = String(Int(minHorsepowerSlider.value)) + " hp" // cast slider's value to int first to round for safety reasons
        if let currentSearchFilter = self.searchFilter {
            currentSearchFilter.minHP = Int(self.minHorsepowerSlider.value) // also round here
        }
    }
    
    // get number of rows in a table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int
        
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
            count = 0
            print("non-intended use of FilterViewController as delegate for an unknown table view (in numberOfRowsInSection)")
        }
        return count
    }
    
    // get cell for specific row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellContent:SelectableItem
        var cellIdentifier:String
        
        switch tableView {
        case self.pickExtraTable:
            cellIdentifier = PICK_EXTRA_TABLE_CELL_IDENTIFIER
            cellContent = self.features[indexPath.row]
        case self.pickFuelTable:
            cellIdentifier = PICK_FUEL_TABLE_CELL_IDENTIFIER
            cellContent = fuels[indexPath.row]
        case self.pickBrandTable:
            cellIdentifier = PICK_BRAND_TABLE_CELL_IDENTIFIER
            cellContent = brands[indexPath.row]
        case self.pickGearTable:
            cellIdentifier = PICK_GEAR_TABLE_CELL_IDENTIFIER
            cellContent = gears[indexPath.row]
        case self.pickVehicleTypeTable:
            cellIdentifier = PICK_VEHICLE_TYPE_TABLE_CELL_IDENTIFIER
            cellContent = vehicleTypes[indexPath.row]
        default:
            print("non-intended use of FilterViewController as delegate for an unknown table view (in numberOfRowsInSection)")
            return UITableViewCell()
        }
        
        let returnCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        returnCell.textLabel!.text = cellContent.name // set cell's text to items name
        if (cellContent.isSelected){
            returnCell.accessoryType = UITableViewCellAccessoryType.checkmark // add checkmark if item is selected
        } else {
            returnCell.accessoryType = UITableViewCellAccessoryType.none // no checkmark if item is not selected
        }
        returnCell.selectionStyle = UITableViewCellSelectionStyle.none // remove blue background selection style
        return returnCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
            // get corresponding item for table view, update selection status of the item and then update the list of selected items of that type in the filter
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
                print("non-intended use of FilterViewController as delegate for an unknown table view (in didSelectRowAt)")
                return
        }
        tableView.reloadRows(at: [indexPath], with: .none) // reload row to reflect new selected status of the item (show checkmark)
    }
    
    func receiveFeatures(features: [Feature]) -> Void {
        self.features = features
        self.pickExtraTable.reloadData() // reload to show new items

        // if a feature filter is set in the filter object ...
        if let selectedFeatureIDs = self.searchFilter?.featureIDs {
            for selectedFeatureID in selectedFeatureIDs {
                // ... get the corresponding feature object for each feature ID by filtering the feature objects
                let featureWithSelectedID = self.features.filter{$0.id == selectedFeatureID}
                if featureWithSelectedID.count == 1 {
                    // corresponding feature object found -> set it to selected
                    featureWithSelectedID[0].isSelected = true
                } else {
                    print("found more than one or no feature with the ID " + String(selectedFeatureID) + "(in receiveFeatures)")
                }
            }
        }
    }
    
    func receiveVehicleTypes(vehicleTypes: [VehicleType]) -> Void {
        self.vehicleTypes = vehicleTypes
        self.pickVehicleTypeTable.reloadData() // reload to show new items
        
        // if a vehicle type filter is set in the filter object ...
        if let selectedVehicleTypeIDs = self.searchFilter?.vehicleTypeIDs {
            for selectedVehicleTypeID in selectedVehicleTypeIDs {
                // ... get the corresponding vehicle type object for each vehicle type ID by filtering the vehicle type objects
                let vehicleTypeWithSelectedID = self.vehicleTypes.filter{$0.id == selectedVehicleTypeID}
                if vehicleTypeWithSelectedID.count == 1 {
                    // corresponding vehicle type object found -> set it to selected
                    vehicleTypeWithSelectedID[0].isSelected = true
                } else {
                    print("found more than one or no vehicle type with the ID " + String(selectedVehicleTypeID) + "(in receiveVehicleTypes)")
                }
            }
        }
    }
    
    func receiveFuels(fuels: [Fuel]) -> Void {
        self.fuels = fuels
        self.pickFuelTable.reloadData() // reload to show new items
        
        // if a fuel filter is set in the filter object ...
        if let selectedFuelIDs = self.searchFilter?.fuelIDs {
            for selectedFuelID in selectedFuelIDs {
                // ... get the corresponding fuel object for each fuel ID by filtering the fuel objects
                let fuelWithSelectedID = self.fuels.filter{$0.id == selectedFuelID}
                if fuelWithSelectedID.count == 1 {
                    // corresponding fuel object found -> set it to selected
                    fuelWithSelectedID[0].isSelected = true
                } else {
                    print("found more than one or no fuel with the ID " + String(selectedFuelID) + "(in receiveFuels)")
                }
            }
        }
    }
    
    func receiveBrands(brands: [Brand]) -> Void {
        self.brands = brands
        self.pickBrandTable.reloadData() // reload to show new items
        
        // if a brand filter is set in the filter object ...
        if let selectedBrandIDs = self.searchFilter?.brandIDs {
             for selectedBrandID in selectedBrandIDs {
                // ... get the corresponding brand object for each brand ID by filtering the brand objects
                let brandWithSelectedID = self.brands.filter{$0.id == selectedBrandID}
                if brandWithSelectedID.count == 1 {
                    // corresponding brand object found -> set it to selected
                    brandWithSelectedID[0].isSelected = true
                } else {
                    print("found more than one or no brand with the ID " + String(selectedBrandID) + "(in receiveBrands)")
                }
             }
        }
    }
    
    func receiveGears(gears: [Gear]) -> Void {
        self.gears = gears
        self.pickGearTable.reloadData() // reload to show new items
        
        // if a gear filter is set in the filter object ...
        if let selectedGearIDs = self.searchFilter?.gearIDs {
            for selectedGearID in selectedGearIDs {
                // ... get the corresponding gear object for each gear ID by filtering the gear objects
                let gearWithSelectedID = self.gears.filter{$0.id == selectedGearID}
                if gearWithSelectedID.count == 1 {
                    // corresponding gear object found -> set it to selected
                    gearWithSelectedID[0].isSelected = true
                } else {
                    print("found more than one or no gear with the ID " + String(selectedGearID) + "(in receiveGears)")
                }
            }
        }
    }
        
    func updateSelectedFeaturesInFilter(){
        if let currentSearchFilter = self.searchFilter {
            let selectedFeatures = self.features.filter{$0.isSelected}
            if (selectedFeatures.count == 0){
                // no features selected -> disable filter and indicate to the user that the filter is disabled
                currentSearchFilter.featureIDs = nil
                self.featuresFilterStatusLabel.text = self.FILTER_DISABLED_TEXT
            } else {
                // feature(s) selected -> enable filter and indicate to the user that the filter is enabled
                currentSearchFilter.featureIDs = selectedFeatures.map{$0.id}
                self.featuresFilterStatusLabel.text = self.FILTER_ENABLED_TEXT
            }
        }
    }
    
    func updateSelectedBrandsInFilter(){
        if let currentSearchFilter = self.searchFilter {
            let selectedBrands = self.brands.filter{$0.isSelected}
            if (selectedBrands.count == 0){
                // no brands selected -> disable filter and indicate to the user that the filter is disabled
                currentSearchFilter.brandIDs = nil
                self.brandsFilterStatusLabel.text = self.FILTER_DISABLED_TEXT
            } else {
                // brand(s) selected -> enable filter and indicate to the user that the filter is enabled
                currentSearchFilter.brandIDs = selectedBrands.map{$0.id}
                self.brandsFilterStatusLabel.text = self.FILTER_ENABLED_TEXT
            }
        }
    }
    
    func updateSelectedGearsInFilter(){
        if let currentSearchFilter = self.searchFilter {
            let selectedGears = self.gears.filter{$0.isSelected}
            if (selectedGears.count == 0){
                // no gears selected -> disable filter and indicate to the user that the filter is disabled
                currentSearchFilter.gearIDs = nil
                self.gearFilterStatusLabel.text = self.FILTER_DISABLED_TEXT
            } else {
                // gear(s) selected -> enable filter and indicate to the user that the filter is enabled
                currentSearchFilter.gearIDs = selectedGears.map{$0.id}
                self.gearFilterStatusLabel.text = self.FILTER_ENABLED_TEXT
            }
        }
    }
    
    func updateSelectedVehicleTypesInFilter(){
        if let currentSearchFilter = self.searchFilter {
            let selectedVehicleTypes = self.vehicleTypes.filter{$0.isSelected}
            if (selectedVehicleTypes.count == 0){
                // no vehicle types selected -> disable filter and indicate to the user that the filter is disabled
                currentSearchFilter.vehicleTypeIDs = nil
                self.vehicleTypeFilterStatusLabel.text = self.FILTER_DISABLED_TEXT
            } else {
                // vehicle type(s) selected -> enable filter and indicate to the user that the filter is enabled
                currentSearchFilter.vehicleTypeIDs = selectedVehicleTypes.map{$0.id}
                self.vehicleTypeFilterStatusLabel.text = self.FILTER_ENABLED_TEXT
            }
        }
    }
    
    func updateSelectedFuelsInFilter(){
        if let currentSearchFilter = self.searchFilter {
            let selectedFuels = self.fuels.filter{$0.isSelected}
            if (selectedFuels.count == 0){
                // no fuels selected -> disable filter and indicate to the user that the filter is disabled
                currentSearchFilter.fuelIDs = nil
                self.fuelFilterStatusLabel.text = self.FILTER_DISABLED_TEXT
            } else {
                // fuel(s) selected -> enable filter and indicate to the user that the filter is enabled
                currentSearchFilter.fuelIDs = selectedFuels.map{$0.id}
                self.fuelFilterStatusLabel.text = self.FILTER_ENABLED_TEXT
            }
        }
    }

}
