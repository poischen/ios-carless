//
//  ChatViewController.swift
//  ios
//
//  Created by Jelena Pranjic on 29.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FetchData {
    
    
    @IBOutlet weak var myTV: UITableView!
    
    private let CHAT_SEGUE = "ChatSegue";
    
    //Array of Users to store all of the users
    private var users = [User]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Fetch Data has to know that we have confirmed to the protocol
        //chatVC deals with the function dataReceived(); 
        StorageAPI.shared.delegate = self;
        StorageAPI.shared.getUsers();
    }
    
    //what is done when data is received
    func dataReceived(users: [User]) {
        self.users = users;
        
        //get the name of current user
        for user in users {
            if user.id == StorageAPI.shared.userID() {
                StorageAPI.shared.userName = user.name;
            }
        }
        
        myTV.reloadData();
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count;
    }
    
    //it will reuse the same cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath);
        
        
        cell.textLabel?.text = users[indexPath.row].name;
        
        return cell;
    }
    
    //open chat window
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: CHAT_SEGUE, sender: nil)
    }

    //go back to the View Controller before (there's none for now)
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
 
    
}