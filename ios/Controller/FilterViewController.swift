//
//  FilterViewController.swift
//  ios
//
//  Created by Konrad Fischer on 09.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    @IBOutlet weak var applyFilterButton: UIButton!
    
    var features = [Feature]()
    var vehicleTypes = [VehicleType]()
    
    var fuel = [
        Fuel(name: "diesel"),
        Fuel(name: "benzine"),
        Fuel(name: "electric"),
        Fuel(name: "hybrid"),
        Fuel(name: "natural gas"),
        Fuel(name: "hydrogen")
    ] // TODO: move to better location
    
    var brands:[Brand] = [
        Brand(id: 0, name: "BMW"),
        Brand(id: 1, name: "Audi")
    ]
    
    var gears:[Gear] = [
        Gear(name: "shift"),
        Gear(name: "automatic")
    ]
    
    let notificationCenter: NotificationCenter = NotificationCenter.default
    let storageAPI: StorageAPI = StorageAPI.shared
    let searchModel: SearchModel = SearchModel()
    var searchFilter:Filter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        /* notificationCenter.addObserver(
            forName:Notification.Name(rawValue:"sendExtras"),
            object:nil,
            queue:nil,
            using:receiveFeatures
        )*/
        storageAPI.getFeatures(completion: self.receiveFeatures)
        storageAPI.getVehicleTypes(completion: self.receiveVehicleTypes)
        
        // TESTING
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        if let brands = self.searchFilter?.brands {
            self.pickBrandTable.reloadData() // added because table cells seem to be not available at this point until the table is reloaded
            for brand in brands {
                pickBrandTable.cellForRow(at: IndexPath(row: brand.id, section: 0))?.accessoryType = UITableViewCellAccessoryType.checkmark
                self.brands[brand.id].isSelected = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func maxPriceChanged(_ sender: Any) {
        maxPriceLabel.text = String(Int(maxPriceSlider.value)) + "€"
    }
    
    @IBAction func maxMileageChanged(_ sender: Any) {
        maxConsumptionLabel.text = String(Int(maxConsumptionSlider.value)) + " l/100km"
    }
    
    @IBAction func maxHorsepowerChanged(_ sender: Any) {
        minHorsepowerLabel.text = String(Int(minHorsepowerSlider.value)) + " hp"
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
            count = fuel.count
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
        
        var returnCell: UITableViewCell?
        
        // TODO: avoid code duplication here by merging Engine, Feature and Gear?
        
        switch tableView {
        case self.pickExtraTable:
            let cellIdentifier = "ExtraTableViewCell"
            let extra:Feature = self.features[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = extra.name
            returnCell = cell
        case self.pickFuelTable:
            let cellIdentifier = "EngineTableViewCell"
            let engine:Fuel = fuel[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = engine.name
            returnCell = cell
        case self.pickBrandTable:
            let cellIdentifier = "BrandTableViewCell"
            let brand:Brand = brands[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = brand.name
            returnCell = cell
        case self.pickGearTable:
            let cellIdentifier = "GearTableViewCell"
            let gear:Gear = gears[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = gear.name
            returnCell = cell
        case self.pickVehicleTypeTable:
            let cellIdentifier = "VehicleTypeTableViewCell"
            let carType:VehicleType = vehicleTypes[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = carType.name
            returnCell = cell
        default:
            returnCell = nil
        }

        
        returnCell!.selectionStyle = UITableViewCellSelectionStyle.none
        return returnCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // TODO: avoid code duplication here by merging Engine, Feature and Gear

        
        switch tableView {
        case self.pickExtraTable:
            let feature = self.features[indexPath.row]
            if (feature.isSelected){
                pickExtraTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            } else {
                pickExtraTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            feature.toggleSelected()
        case self.pickFuelTable:
            let engine = self.fuel[indexPath.row]
            // TODO: avoid code duplication here
            if (engine.isSelected){
                pickFuelTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            } else {
                pickFuelTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            engine.toggleSelected()
        case self.pickBrandTable:
            let brand = self.brands[indexPath.row]
            if (brand.isSelected){
                pickBrandTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            } else {
                pickBrandTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            brand.toggleSelected()
        case self.pickGearTable:
            let gear = self.gears[indexPath.row]
            if (gear.isSelected){
                pickGearTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            } else {
                pickGearTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            gear.toggleSelected()
        case self.pickVehicleTypeTable:
            let carType:VehicleType = self.vehicleTypes[indexPath.row]
            if (carType.isSelected){
                pickVehicleTypeTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            } else {
                pickVehicleTypeTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            carType.toggleSelected()
        default:
            return
        }
    }
    
    func receiveFeatures(features: [Feature]) -> Void {
        self.features = features
        self.pickExtraTable.reloadData()
        // restore selected features here as they can only be restored after receiving them from the DB -> viewWillAppear doesn't work
        if let featureIDs = self.searchFilter?.featureIDs {
            for featureID in featureIDs {
                pickExtraTable.cellForRow(at: IndexPath(row: featureID, section: 0))?.accessoryType = UITableViewCellAccessoryType.checkmark
                self.features[featureID].isSelected = true
            }
        }
    }
    
    func receiveVehicleTypes(vehicleTypes: [VehicleType]) -> Void {
        self.vehicleTypes = vehicleTypes
        self.pickVehicleTypeTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "applyFilters") {
            // next screen: search results
            if let searchResultsController = segue.destination as? SearchResultsViewController {
                if var currentSearchFilter = self.searchFilter {
                    currentSearchFilter.maxConsumption = Int(self.maxConsumptionSlider.value)
                    currentSearchFilter.minHP = Int(self.minHorsepowerSlider.value)
                    currentSearchFilter.gearshifts = self.gears.filter {return $0.isSelected}
                    currentSearchFilter.brands = self.brands.filter {return $0.isSelected}
                    currentSearchFilter.engines = self.fuel.filter {return $0.isSelected}
                    currentSearchFilter.featureIDs = self.features.reduce([]) {result, feature in
                        if (feature.isSelected){
                            return result! + [feature.id]
                        } else {
                            return result
                        }
                    }
                    currentSearchFilter.vehicleTypeIDs = self.vehicleTypes.reduce([]) {result, vehicleType in
                        if (vehicleType.isSelected){
                            return result! + [vehicleType.id]
                        } else {
                            return result
                        }
                    }
                    currentSearchFilter.maxPrice = Int(self.maxPriceSlider.value)
                    self.searchFilter = currentSearchFilter
                    searchResultsController.searchFilter = currentSearchFilter
                    //self.searchModel.getFilteredOfferings(filter: currentSearchFilter, completion: searchResultsController.receiveOfferings)
                }
            }
        }
    }

}
