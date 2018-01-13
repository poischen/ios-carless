//
//  ProfileViewController.swift
//  ios
//
//  Created by Hila Safi on 19.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import InteractiveSideMenu

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SideMenuItemContent {

   
    @IBOutlet weak var imageView: UIImageView!
 
   
    @IBAction func chooseImage(_ sender: Any) {

    
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: . actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action:UIAlertAction) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else {
                print ("Camera not available")
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
        
        imageView.image=image
        
        picker.dismiss(animated:true, completion:nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated:true, completion:nil)
    }
    
    
  
    @IBAction func logout(_ sender: Any) {
    
    if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Main")
                self.present(vc!, animated: true, completion: nil)
                present(vc!, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // temporary link, remove later
    @IBAction func searchButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SearchNavigation")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func advertiseButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Advertise", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AdvertisePages")
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func chatButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "ChatStoryboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Chat")
        self.present(vc, animated: true, completion: nil)
    }

    @IBAction func rateButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Rate", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Rate")
        self.present(vc, animated: true, completion: nil)
    }
    
    
    @IBAction func menuButtonClicked(_ sender: Any) {
        showSideMenu()
    }
    
}
