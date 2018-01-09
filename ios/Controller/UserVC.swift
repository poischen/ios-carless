//
//  ChatViewController.swift
//  ios
//
//  Created by Jelena Pranjic on 29.11.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit
import Firebase


class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FetchData {
    
    
    @IBOutlet weak var myTV: UITableView!
    
    private let CHAT_SEGUE = "ChatSegue";
    
    //Array of Users to store all of the users
    private var users = [User]();
    
    var selctedUser: String = ""
    static let sharedChat = ChatViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Fetch Data has to know that we have confirmed to the protocol
        //chatVC deals with the function dataReceived(); 
        //StorageAPI.shared.delegate = self;
        StorageAPI.shared.getUsers(completion: dataReceived);
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
        
        cell.textLabel?.text = users[indexPath.row].name

        return cell;
    }
    
    //open chat window
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUserObject = self.users[indexPath.row]

        self.selctedUser = selectedUserObject.id
            let ref = Database.database().reference().child(DBConstants.USERS).child(self.selctedUser)
            ref.observeSingleEvent(of: .value, with: {(snapshot) in
               
                self.performSegue(withIdentifier: self.CHAT_SEGUE, sender: nil)
                })
        
        
    }

    //go back to the View Controller before the current one
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNavigationController = segue.destination as! UINavigationController
        let targetController = destinationNavigationController.topViewController
            if let chatVC = targetController as? ChatWindowVC {
                chatVC.receiverId = self.selctedUser
                observeMessages()
                observeMediaMessages()
            }
        
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(DataEventType.childAdded){ (snapshot: DataSnapshot) in
            let messageID = snapshot.key
            let messagesRef = Database.database().reference().child(DBConstants.MESSAGES).child(messageID)
            messagesRef.observeSingleEvent(of: .value, with: {snapshot in
                if let data = snapshot.value as? NSDictionary {
                    if let senderID = data[DBConstants.SENDER_ID] as? String{
                        if let receiverID = data[DBConstants.RECEIVER_ID] as? String {
                            if let text = data[DBConstants.TEXT] as? String {
                            if (receiverID == self.selctedUser) || (senderID == self.selctedUser) {
                                    MessageHandler._shared.delegate?.messageReceived(senderID: senderID, receiverID: receiverID, text: text)
                                }
                            }
                        }
                    }
                }
                
            })
        }
    }
    
    func observeMediaMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userMessagesRef = Database.database().reference().child("user-messages").child(uid)
        userMessagesRef.observe(DataEventType.childAdded){ (snapshot: DataSnapshot) in
            let messageID = snapshot.key
            let messagesRef = Database.database().reference().child(DBConstants.MEDIA_MESSAGES).child(messageID)
            messagesRef.observeSingleEvent(of: .value, with: {snapshot in
                if let data = snapshot.value as? NSDictionary {
                    if let senderID = data[DBConstants.SENDER_ID] as? String{
                        if let receiverID = data[DBConstants.RECEIVER_ID] as? String {
                          if let name = data[DBConstants.NAME] as? String {
                            if let fileURL = data[DBConstants.URL] as? String {
                                if (receiverID == self.selctedUser) || (senderID == self.selctedUser) {
                                    MessageHandler._shared.delegate?.mediaReceived(senderID: senderID, senderName: name, url: fileURL)
                                   }
                                }
                            }
                        }
                    }
                }
                
            })
        }
        
    }
    /*func observeMediaMessages() {
     
     StorageAPI.shared.mediaMessagesRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
     
     if let data = snapshot.value as? NSDictionary {
     if let id = data[DBConstants.SENDER_ID] as? String {
     if let name = data[DBConstants.SENDER_NAME] as?
     String {
     if let fileURL = data[DBConstants.URL] as?
     String {
     self.delegate?.mediaReceived(senderID: id, senderName: name, url: fileURL);
     }
     }
     }
     }
     }
     }*/
 
}
