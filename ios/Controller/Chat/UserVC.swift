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
        //gets all the useres that are saved in the database
        StorageAPI.shared.getUsers(completion: dataReceived)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func dataReceived(users: [User]) {
        //filters out your own name
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

        let palceholderImg: UIImage = UIImage(named: "ProfilePic")!
        cell.imageView?.maskCircle(anyImage: palceholderImg)
        
        let userImg = URL(string: users[indexPath.row].profileImgUrl)
        //cell.imageView?.kf.setImage(with: userImg)
        
        cell.imageView?.kf.setImage(with: userImg, completionHandler: {
            (image, error, cacheType, imageUrl) in
            cell.imageView?.maskCircle(anyImage: (cell.imageView?.image)!)
        })
        
        return cell
    }

    /* when a user is tapped his chat window opens */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == CHAT_SEGUE,
        let chatVC = segue.destination as? ChatWindowVC,
        let indexPath = myTableView.indexPathForSelectedRow {
            
            let index = indexPath.row
            
            //get the UID (receiverID for the message) of the selected User
            let selectedUserObject = self.users[index]
            self.selectedUser = selectedUserObject.id
            self.selectedUserName = selectedUserObject.name
            
            if let image: UIImage = myTableView.cellForRow(at: indexPath)?.imageView?.image {
                self.selectedUserImage = image
            }
            
            chatVC.receiverID = self.selectedUser
            chatVC.selectedUser = self.selectedUser
            chatVC.receiverName = self.selectedUserName
            chatVC.receiverImage = self.selectedUserImage
        }
    }
}
