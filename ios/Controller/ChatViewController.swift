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
    
    //Array of Users to store all of the users
    private var users = [User]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DBProvider.Instance.delegate = self;
        DBProvider.Instance.getUsers();
    }
    
    func dataReceived(users: [User]) {
        self.users = users;
        
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

    //go back to the View Controller before (there's none for now)
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
}
