//
//  AdvertisePage1.swift
//  ios
//
//  Created by admin on 27.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

/*
 * advertise vehicle image
 */

class AdvertisePage1: UIViewController, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate {
    
    var picker: UIImagePickerController? = UIImagePickerController()
    
    @IBOutlet weak var carImageView: UIImageView!
    @IBAction func chooseImgButton(_ sender: Any) {
        chooseImage()
    }
    
    //Camera stuff
    func chooseImage (){
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: . actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else {
                print ("Camera not available")
                let alertTest = UIAlertController(title: "Something went wrong", message: "Camera not available", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
                alertTest.addAction(ok)
                self.present(alertTest, animated: true, completion: nil)
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action:UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated:true, completion:nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler:nil ))
        
        self.present(actionSheet, animated: true, completion:nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        carImageView.image=image
        //store UI Image
        picker.dismiss(animated:true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion:nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker?.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}