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
    @IBOutlet weak var maxMileageLabel: UILabel!
    @IBOutlet weak var maxMileageSlider: UISlider!
    @IBOutlet weak var minHorsepowerLabel: UILabel!
    @IBOutlet weak var minHorsepowerSlider: UISlider!
    
    @IBOutlet weak var pickExtraTable: UITableView!
    @IBOutlet weak var pickEngineTable: UITableView!
    @IBOutlet weak var pickBrandTable: UITableView!
    @IBOutlet weak var applyFilterButton: UIButton!
    
    var extras = [Feature]()
    
    var engines = [Engine(name: "Diesel", id: 0), Engine(name: "Benzin", id: 1), Engine(name: "Elektro", id:2), Engine(name: "Hybrid", id: 3), Engine(name: "Erdgas", id: 3), Engine(name: "Wasserstoff", id: 3)] // TODO: move to better location
    
    var brands:[Brand] = [Brand(name: "BMW"), Brand(name: "Audi")]
    
    let notificationCenter: NotificationCenter = NotificationCenter.default
    let storageAPI: StorageAPI = StorageAPI.shared
    let model: SearchModel = SearchModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickEngineTable.delegate = self
        pickEngineTable.dataSource = self
        pickExtraTable.delegate = self
        pickExtraTable.dataSource = self
        pickBrandTable.delegate = self
        pickBrandTable.dataSource = self
        
        notificationCenter.addObserver(
            forName:Notification.Name(rawValue:"sendExtras"),
            object:nil,
            queue:nil,
            using:receiveExtras
        )
        storageAPI.getExtras()
        
        // TESTING
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func maxPriceChanged(_ sender: Any) {
        maxPriceLabel.text = String(Int(maxPriceSlider.value)) + "€"
    }
    
    @IBAction func maxDistanceChanged(_ sender: Any) {
        maxDistanceLabel.text = String(Int(maxDistanceSlider.value)) + " km"
    }
    
    @IBAction func maxMileageChanged(_ sender: Any) {
        maxMileageLabel.text = String(Int(maxMileageSlider.value)) + "l/100km"
    }
    
    @IBAction func maxHorsepowerChanged(_ sender: Any) {
        minHorsepowerLabel.text = String(Int(minHorsepowerSlider.value)) + " hp"
    }

    
    @IBAction func applyFiltersClicked(_ sender: Any) {
        model.filterOfferings(filter: Filter(maxPrice: 10))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        
        switch tableView {
        case self.pickExtraTable:
            count = extras.count
        case self.pickEngineTable:
            count = engines.count
        case self.pickBrandTable:
            count = brands.count
        default:
            count = nil
        }

        
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var returnCell: UITableViewCell?
        
        switch tableView {
        case self.pickExtraTable:
            let cellIdentifier = "ExtraTableViewCell"
            let extra = extras[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = extra.name
            returnCell = cell
        case self.pickEngineTable:
            let cellIdentifier = "EngineTableViewCell"
            let engine = engines[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = engine.name
            returnCell = cell
        case self.pickBrandTable:
            let cellIdentifier = "BrandTableViewCell"
            let brand = brands[indexPath.row]
            let cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell!.textLabel!.text = brand.name
            returnCell = cell
        default:
            returnCell = nil
        }

        
        returnCell!.selectionStyle = UITableViewCellSelectionStyle.none
        return returnCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView {
        case self.pickExtraTable:
            let extra = self.extras[indexPath.row]
            if (extra.isSelected){
                pickExtraTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            } else {
                pickExtraTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            extra.toggleSelected()
        case self.pickEngineTable:
            let engine = self.engines[indexPath.row]
            // TODO: avoid code duplication here
            if (engine.isSelected){
                pickEngineTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            } else {
                pickEngineTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
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
        default:
            return
        }
    }
    
    // TODO: also hardcode the extras as it's unlikely that new ones will be created
    func receiveExtras(notification: Notification) -> Void {
        guard let userInfo = notification.userInfo,
            let receivedExtras  = userInfo["extras"] as? [Feature] else {
                print("No userInfo found in notification")
                return
        }
        
        self.extras = receivedExtras
        self.pickExtraTable.reloadData()
    }

}
