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
    @IBOutlet weak var maxDistanceLabel: UILabel!
    @IBOutlet weak var maxDistanceSlider: UISlider!
    @IBOutlet weak var maxConsumptionLabel: UILabel!
    @IBOutlet weak var maxConsumptionSlider: UISlider!
    @IBOutlet weak var minHorsepowerLabel: UILabel!
    @IBOutlet weak var minHorsepowerSlider: UISlider!
    
    @IBOutlet weak var pickExtraTable: UITableView!
    @IBOutlet weak var pickFuelTable: UITableView!
    @IBOutlet weak var pickBrandTable: UITableView!
    @IBOutlet weak var pickGearTable: UITableView!
    @IBOutlet weak var applyFilterButton: UIButton!
    
    var features = [Feature]()
    
    var fuel = [
        Fuel(name: "diesel"),
        Fuel(name: "benzine"),
        Fuel(name: "electric"),
        Fuel(name: "hybrid"),
        Fuel(name: "natural gas"),
        Fuel(name: "hydrogen")
    ] // TODO: move to better location
    
    var brands:[Brand] = [
        Brand(name: "BMW"),
        Brand(name: "Audi")
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
        
        /* notificationCenter.addObserver(
            forName:Notification.Name(rawValue:"sendExtras"),
            object:nil,
            queue:nil,
            using:receiveFeatures
        )*/
        storageAPI.getFeatures(completion: self.receiveFeatures)
        
        // TESTING
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func maxPriceChanged(_ sender: Any) {
        maxPriceLabel.text = String(Int(maxPriceSlider.value)) + "€"
    }
    
    @IBAction func maxMileageChanged(_ sender: Any) {
        maxConsumptionLabel.text = String(Int(maxConsumptionSlider.value)) + "l/100km"
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
            let extra = self.features[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = extra.name
            returnCell = cell
        case self.pickFuelTable:
            let cellIdentifier = "EngineTableViewCell"
            let engine = fuel[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = engine.name
            returnCell = cell
        case self.pickBrandTable:
            let cellIdentifier = "BrandTableViewCell"
            let brand = brands[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = brand.name
            returnCell = cell
        case self.pickGearTable:
            let cellIdentifier = "GearTableViewCell"
            let gear = gears[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = gear.name
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
        default:
            return
        }
    }
    
    // TODO: also hardcode the extras as it's unlikely that new ones will be created?
    func receiveFeatures(features: [Feature]) -> Void {
        self.features = features
        self.pickExtraTable.reloadData()
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
                    currentSearchFilter.maxPrice = Int(self.maxPriceSlider.value)
                    searchResultsController.searchFilter = currentSearchFilter
                    //self.searchModel.getFilteredOfferings(filter: currentSearchFilter, completion: searchResultsController.receiveOfferings)
                }
            }
        }
    }

}
