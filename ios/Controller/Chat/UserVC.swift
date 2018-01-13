//
//  ChatViewController.swift
//  ios
//
//  Created by Jelena Pranjic on 29.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit
import Firebase


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var users = [User]()
    
   
    @IBOutlet weak var myTableView: UITableView!
    
    private let CHAT_SEGUE = "ChatSegue"
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        StorageAPI.shared.getUsers(completion: dataReceived)
        
    }
    
    func dataReceived(users: [User]) {
        self.users = users
        myTableView.reloadData()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let selectedUserObject = self.users[indexPath.row]
        
        //self.selectedUser = selectedUserObject.id
       // let ref = Database.database().reference().child(DBConstants.USERS).child(self.selectedUser)
        //ref.observeSingleEvent(of: .value, with: {(snapshot) in
            
            performSegue(withIdentifier: CHAT_SEGUE, sender: nil)
        //})
    
    }


    
    //Back Button that goes back to the View before this one
    @IBAction func backButtonUserVC(_ sender: Any) {
         dismiss(animated: true, completion: nil);
    }
    
}
