//
//  ChatViewController.swift
//  ios
//
//  Created by Jelena Pranjic on 29.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit
import Kingfisher

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var users = [User]()
    
    //receiverID
    var selectedUser: String = ""
    var selectedUserName: String = ""
    var selectedUserImage: UIImage?
    
    @IBOutlet weak var myTableView: UITableView!
    
    private let CHAT_SEGUE = "ChatSegue"
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        StorageAPI.shared.getUsers(completion: dataReceived)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
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
        let userImg = URL(string: users[indexPath.row].profileImgUrl)
        cell.imageView?.kf.indicatorType = .activity
        cell.imageView?.kf.setImage(with: userImg, placeholder: UIImage(named: "ProfilePic"))

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUserObject = self.users[indexPath.row]
        self.selectedUser = selectedUserObject.id
        self.selectedUserName = selectedUserObject.name
        
        if let image: UIImage = tableView.cellForRow(at: indexPath)?.imageView?.image {
            self.selectedUserImage = image
        }
       //performSegue(withIdentifier: CHAT_SEGUE, sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == CHAT_SEGUE) {

            print(self.selectedUser)
            let chatVC = segue.destination as! ChatWindowVC
            chatVC.receiverID = self.selectedUser
            chatVC.selectedUser = self.selectedUser
            chatVC.receiverName = self.selectedUserName
            
            if let image: UIImage = self.selectedUserImage {
                chatVC.receiverImage = image
            }
        }
    }
    
    
    //Back Button that goes back to the View before this one
    @IBAction func backButtonUserVC(_ sender: Any) {
         dismiss(animated: true, completion: nil);
    }
    
}
