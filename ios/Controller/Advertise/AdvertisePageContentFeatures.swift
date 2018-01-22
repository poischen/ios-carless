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

class AdvertisePageContentFeatures: UIViewController {
    
    var pageViewController: AdvertisePagesVC!
    let storageAPI = StorageAPI.shared
    
    @IBOutlet weak var featuresCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        featuresCollectionView.delegate = self
        featuresCollectionView.dataSource = self
        
        pageViewController = self.parent as! AdvertisePagesVC

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AdvertisePageContentFeatures: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageViewController.advertise.featuresImages.count
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
        featureCell.featureIconImageView.image = pageViewController.advertise.featuresImages[indexPath.row]
        featureCell.featureLabel.text = pageViewController.advertise.featuresLabels[indexPath.row]
        featureCell.awakeFromNib()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension AdvertisePageContentFeatures: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let featureCell = featuresCollectionView.cellForItem(at: indexPath) as! AdvertiseFeaturesCollectionViewCell
        featureCell.featureChecked.isHidden = false
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let featureCell = featuresCollectionView.cellForItem(at: indexPath) as! AdvertiseFeaturesCollectionViewCell
        featureCell.featureChecked.isHidden = true
    }
    
}
