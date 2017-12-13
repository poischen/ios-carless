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
        
        storageAPI.getFeatures(completion: self.receiveFeatures)
        storageAPI.getVehicleTypes(completion: self.receiveVehicleTypes)
        storageAPI.getBrands(completion: self.receiveBrands)
        storageAPI.getFuels(completion: self.receiveFuels)
        storageAPI.getGears(completion: self.receiveGears)
        
        // TESTING
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // restore UI state when the filter view is opened again
        /* if let currentMaxPrice = self.searchFilter?.maxPrice {
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
        } */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func maxPriceChanged(_ sender: Any) {
        maxPriceLabel.text = String(Int(maxPriceSlider.value)) + "€"
    }
    
    @IBAction func maxConsumptionChanged(_ sender: Any) {
        maxConsumptionLabel.text = String(Int(maxConsumptionSlider.value)) + " l/100km"
        if self.searchFilter != nil {
            self.searchFilter!.maxConsumption = Int(self.maxConsumptionSlider.value)
        }
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
        
        var returnCell: UITableViewCell?
        
        // TODO: avoid code duplication here by merging Engine, Feature and Gear?
        // TODO: gracefully handle errors here
        
        switch tableView {
        case self.pickExtraTable:
            let cellIdentifier = "ExtraTableViewCell"
            let extra:Feature = self.features[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = extra.name
            if (extra.isSelected){
                cell!.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.none
            }
            returnCell = cell
        case self.pickFuelTable:
            let cellIdentifier = "EngineTableViewCell"
            let fuel:Fuel = fuels[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = fuel.name
            if (fuel.isSelected){
                cell!.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.none
            }
            returnCell = cell
        case self.pickBrandTable:
            let cellIdentifier = "BrandTableViewCell"
            let brand:Brand = brands[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = brand.name
            if (brand.isSelected){
                cell!.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.none
            }
            returnCell = cell
        case self.pickGearTable:
            let cellIdentifier = "GearTableViewCell"
            let gear:Gear = gears[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = gear.name
            if (gear.isSelected){
                cell!.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.none
            }
            returnCell = cell
        case self.pickVehicleTypeTable:
            let cellIdentifier = "VehicleTypeTableViewCell"
            let carType:VehicleType = vehicleTypes[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = carType.name
            if (carType.isSelected){
                cell!.accessoryType = UITableViewCellAccessoryType.checkmark
            } else {
                cell!.accessoryType = UITableViewCellAccessoryType.none
            }
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
            feature.toggleSelected()
            self.pickExtraTable.reloadRows(at: [indexPath], with: .none)
        case self.pickFuelTable:
            let engine = self.fuels[indexPath.row]
            // TODO: avoid code duplication here
            engine.toggleSelected()
            self.pickFuelTable.reloadRows(at: [indexPath], with: .none)
        case self.pickBrandTable:
            let brand = self.brands[indexPath.row]
            brand.toggleSelected()
            self.pickBrandTable.reloadRows(at: [indexPath], with: .none)
        case self.pickGearTable:
            let gear = self.gears[indexPath.row]
            gear.toggleSelected()
            self.pickGearTable.reloadRows(at: [indexPath], with: .none)
        case self.pickVehicleTypeTable:
            let carType:VehicleType = self.vehicleTypes[indexPath.row]
            carType.toggleSelected()
            self.pickVehicleTypeTable.reloadRows(at: [indexPath], with: .none)
        default:
            return
        }
    }
    
    func receiveFeatures(features: [Feature]) -> Void {
        self.features = features
        self.pickExtraTable.reloadData()
        // restore selected features here as they can only be restored after receiving them from the DB -> viewWillAppear doesn't work
        // TODO: move to viewWillAppear somehow
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
    
    func receiveFuels(fuels: [Fuel]) -> Void {
        self.fuels = fuels
        self.pickFuelTable.reloadData()
    }
    
    func receiveBrands(brands: [Brand]) -> Void {
        self.brands = brands
        self.pickBrandTable.reloadData()
        
        if let brands = self.searchFilter?.brandIDs {
            //self.pickBrandTable.reloadData() // added because table cells seem to be not available at this point until the table is reloaded
             for i in 0..<brands.count {
                pickBrandTable.cellForRow(at: IndexPath(row: i, section: 0))?.accessoryType = UITableViewCellAccessoryType.checkmark
                self.brands.filter{$0.id == brands[i]}[0].isSelected = true
             }
        }
    }
    
    func receiveGears(gears: [Gear]) -> Void {
        self.gears = gears
        self.pickGearTable.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.searchFilter != nil {
            self.searchFilter?.maxConsumption = Int(self.maxConsumptionSlider.value)
            self.searchFilter?.minHP = Int(self.minHorsepowerSlider.value)
            self.searchFilter?.gearIDs = self.gears.filter{$0.isSelected}.map{$0.id}
            self.searchFilter?.brandIDs = self.brands.filter{$0.isSelected}.map{$0.id}
            self.searchFilter?.fuelIDs = self.fuels.filter{$0.isSelected}.map{$0.id}
            self.searchFilter?.featureIDs = self.features.filter{$0.isSelected}.map{$0.id}
            self.searchFilter?.vehicleTypeIDs = self.vehicleTypes.filter{$0.isSelected}.map{$0.id}
            self.searchFilter?.maxPrice = Int(self.maxPriceSlider.value)
        }
    }

}
