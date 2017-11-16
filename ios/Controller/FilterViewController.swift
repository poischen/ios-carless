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
    
    @IBOutlet weak var pickExtraTable: UITableView!
    @IBOutlet weak var pickEngineTable: UITableView!
    
    var extras = [Extra]()
    var engines = [Engine(name: "Diesel", id: 0), Engine(name: "Benzin", id: 1)]
    let notificationCenter: NotificationCenter = NotificationCenter.default
    let storageAPI: StorageAPI = StorageAPI.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickExtraTable.delegate = self
        pickExtraTable.dataSource = self
        pickEngineTable.delegate = self
        pickExtraTable.delegate = self
        
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        
        if (tableView == self.pickExtraTable){
            count = extras.count
        } else if (tableView == self.pickEngineTable){
            count = engines.count
            print("hallo1")
        }
        
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var returnCell: UITableViewCell?
        
        if (tableView == self.pickExtraTable){
            let cellIdentifier = "ExtraTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ExtraTableViewCell else {
                fatalError("The dequeued cell is not an instance of ExtraTableViewCell.")
            }
            
            let extra = extras[indexPath.row]
            cell.extraNameLabel.text = extra.name
            returnCell = cell
        } else if (tableView === self.pickEngineTable){
            let cellIdentifier = "EngineTableViewCell"
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EngineTableViewCell else {
                fatalError("The dequeued cell is not an instance of EngineTableViewCell.")
            }
            
            let engine = engines[indexPath.row] // TODO: avoid code duplication here?
            cell.engineNameLabel.text = engine.name
            returnCell = cell
            print("hallo")
        }
        
        return returnCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == self.pickExtraTable){
            let extra = self.extras[indexPath.row]
            if (extra.isSelected){
                pickExtraTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            } else {
                pickExtraTable.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            extra.toggleSelected()
        }
    }
    
    func receiveExtras(notification: Notification) -> Void {
        guard let userInfo = notification.userInfo,
            let receivedExtras  = userInfo["extras"] as? [Extra] else {
                print("No userInfo found in notification")
                return
        }
        
        self.extras = receivedExtras
        self.pickExtraTable.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
