//
//  ChatViewController.swift
//  ios
//
//  Created by Jelena Pranjic on 29.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var users = [User]()
    
    //receiverID
    var selectedUser: String = ""
   
    @IBOutlet weak var myTableView: UITableView!
    
    private let CHAT_SEGUE = "ChatSegue"
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        StorageAPI.shared.getUsers(completion: dataReceived)
    }
    
    func dataReceived(users: [User]) {
        self.users = users.filter {$0.id != StorageAPI.shared.userID()}
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
        let selectedUserObject = self.users[indexPath.row]
        self.selectedUser = selectedUserObject.id
        performSegue(withIdentifier: CHAT_SEGUE, sender: nil)
    
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNavigationController = segue.destination as! UINavigationController
        let targetController = destinationNavigationController.topViewController
       if let chatVC = targetController as? ChatWindowVC {
            chatVC.receiverID = self.selectedUser
             chatVC.selectedUser = self.selectedUser
        }
        
    }
    
    
    //Back Button that goes back to the View before this one
    @IBAction func backButtonUserVC(_ sender: Any) {
         dismiss(animated: true, completion: nil);
    }
    
}
