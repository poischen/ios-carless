//
//  AdvertisePage3.swift
//  ios
//
//  Created by admin on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

/*
 * advertise vehicle features
 */

class AdvertisePage3: UIViewController {
    
    var pageViewController: AdvertisePagesVC!
    
    @IBOutlet weak var featuresCollectionView: UICollectionView!
    
    //TODO: Use data from DB
    var featuresImages = [UIImage(named: "navigation"), UIImage(named: "cruise_controll"), UIImage(named: "seat_heater"), UIImage(named: "infant_seat"), UIImage(named: "AC"), UIImage(named: "park_assistant"), UIImage(named: "front-camera"), UIImage(named: "back-camera"), UIImage(named: "cd_radio_mp3"), UIImage(named: "pre-heating"), UIImage(named: "wifi"), UIImage(named: "start_stop")]
    
        var featuresLabels = ["Navigation", "Cruise controll", "Seat heater", "Infant seat", "AC", "Park assistant", "Front camera", "Back camera", "CD/Radio/Mp3", "Pre-heating", "Wifi", "Start/Stop"]
    
 /*   func setupFeaturesCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        featuresCollectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        featuresCollectionView.register(AdvertiseFeaturesCollectionViewCell.self, forCellWithReuseIdentifier: "featureCell")
        
        featuresCollectionView.backgroundColor = UIColor.white

        
        view.addSubview(featuresCollectionView)
        
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        featuresCollectionView.delegate = self
        featuresCollectionView.dataSource = self
        
      /*  var nib = UINib(nibName: "UICollectionElementKindCell", bundle:nil)
        self.collectionView.registerNib(nib, forCellReuseIdentifier: "CollectionViewCell")*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AdvertisePage3: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return featuresImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = featuresCollectionView.dequeueReusableCell(withReuseIdentifier: "featureCell", for: indexPath) as! AdvertiseFeaturesCollectionViewCell
        cell.awakeFromNib()
        return cell
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let featureCell = cell as! AdvertiseFeaturesCollectionViewCell
        featureCell.featureIconImageView.image = featuresImages[indexPath.row]
        featureCell.featureLabel.text = featuresLabels[indexPath.row]
        featureCell.awakeFromNib()
    }
    
    /*func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: (view.frame.width/4), height: 200)
    }*/
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension AdvertisePage3: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let featureCell = featuresCollectionView.cellForItem(at: indexPath) as! AdvertiseFeaturesCollectionViewCell
        featureCell.featureChecked.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let featureCell = featuresCollectionView.cellForItem(at: indexPath) as! AdvertiseFeaturesCollectionViewCell
        featureCell.featureChecked.isHidden = true
    }
    
}
