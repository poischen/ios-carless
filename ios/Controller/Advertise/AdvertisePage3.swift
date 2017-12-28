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

class AdvertisePage3: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var featuresCollectionView: UICollectionView!
    
    //TODO: Use data from DB
    var featuresImages = [UIImage(named: "navigation"), UIImage(named: "cruise_controll"), UIImage(named: "seat_heater"), UIImage(named: "infant_seat"), UIImage(named: "AC"), UIImage(named: "park_assistant"), UIImage(named: "front-camera"), UIImage(named: "back-camera"), UIImage(named: "cd_radio_mp3"), UIImage(named: "pre-heating"), UIImage(named: "wifi"), UIImage(named: "start_stop")]
    
    func setupFeaturesCollectionView(){
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        featuresCollectionView = UICollectionView(frame: view.frame, collectionViewLayout: layout)
        featuresCollectionView.register(AdvertiseFeaturesCollectionViewCell.self, forCellWithReuseIdentifier: "featureCell")
        
        featuresCollectionView.backgroundColor = UIColor.white
        featuresCollectionView.delegate = self
        featuresCollectionView.dataSource = self
        
        view.addSubview(featuresCollectionView)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFeaturesCollectionView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

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
        featureCell.featureLabel.text = "Test"
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        return CGSize(width: (view.frame.width/4), height: 200)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}
