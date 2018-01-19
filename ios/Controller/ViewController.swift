//
//  ViewController.swift
//  ios
//
//  Created by Hila Safi on 31.10.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class ViewController: UIViewController {
    
    
    //outlets
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //actions
    @IBAction func loginButton(_ sender: Any) {
        login()
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        signup()
    }
    
    
  
    
    
    @IBAction func skipButton(_ sender: Any) {
        _ = self.storyboard?.instantiateViewController(withIdentifier: "Home")
    }
    
    
    //function
    func login() {
        if self.email.text == "" || self.password.text == "" {
            
            //Alert to tell the user that there was an error because they didn't fill anything in the textfields because they didn't fill anything in
            
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        } else {
            
            Auth.auth().signIn(withEmail: self.email.text!, password: self.password.text!) { (user, error) in
                
                if error == nil {
                    
                    //Print into the console if successfully logged in
                    print("You have successfully logged in")
                    
                    //Go to the HomeViewController if the login is sucessful
                    self.goToHome()
                    
                    
                } else {
                    
                    //Tells the user that there is an error and then gets firebase to tell them the error
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
        
    }
    
    func goToHome() {
        let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Navtabs")
        self.present(vc, animated: true, completion: nil)
    }
    
    func signup() {
        if email.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter you E-Mail adress", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler:nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated:true, completion:nil)
        
        } else {
            Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (user, error) in
            
            if error == nil {
                print("You have successfully signed up")
                //Goes to the Setup page which lets the user take a photo for their profile picture and also chose a username
                
                self.goToHome()
                
                StorageAPI.shared.saveUser(withID: user!.uid, name: self.username.text!, email: self.email.text!, rating: 5.0, profileImg: "https://firebasestorage.googleapis.com/v0/b/ioscars-32e69.appspot.com/o/icons%2Fplaceholder%2Fuser.jpg?alt=media&token=5fd1a131-29d6-4a43-8d17-338590e01808");

                
            } else {
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    

}
        
        
        
        
        


