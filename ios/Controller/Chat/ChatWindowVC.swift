//
//  ChatWindowVC.swift
//  ios
//
//  Created by Jelena Pranjic on 03.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import SDWebImage
import Firebase

class ChatWindowVC: JSQMessagesViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    private var messages = [JSQMessage]()
    
    let picker = UIImagePickerController()
    
    var receiverID: String = ""
    
    var selectedUser: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MessageHandler.shared.delegate = self
        
        self.senderId = StorageAPI.shared.userID()
        self.senderDisplayName = StorageAPI.shared.userName
        
        //observeMessages()
        observeUserMessages()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //COLLECTION VIEW FUNCTIONS
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.blue)
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.green)
        }
        
    }
    
    //profile icon
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "ProfilePic"), diameter: 30)
    }

    //display messages
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    //how many messages are in one section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    //pressing send button
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        MessageHandler.shared.handleSend(senderID: senderId, receiverID: self.receiverID, senderName: senderDisplayName, text: text)
        
        //remove text from textfield
        finishSendingMessage()
    }
    
    func addMessage(senderID: String, receiverID: String, senderName: String, text: String) {
       messages.append(JSQMessage(senderId: senderID, displayName: "empty", text: text))
        collectionView.reloadData()
        
    }
    
    //Sending media button
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Media Messages", message: "Please select Media", preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let photos = UIAlertAction(title: "Photos", style: .default, handler: { (alert: UIAlertAction) in self.chooseMedia(type: kUTTypeImage)
        })
        
        let videos = UIAlertAction(title: "Videos", style: .default, handler: { (alert: UIAlertAction) in self.chooseMedia(type: kUTTypeMovie)
        })
        
        alert.addAction(photos)
        alert.addAction(videos)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    //FUNCTIONS FOR PICKER VIEW
    
    private func chooseMedia(type: CFString){
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil)
    }
    
    func observeUserMessages() {
        //logged in user's ID
        guard  let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = StorageAPI.shared.userMessagesRef.child(uid)
        ref.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            let messageID = snapshot.key
            let messageRef = StorageAPI.shared.messagesRef.child(messageID)
            
            messageRef.observeSingleEvent(of: .value, with: {snapshot in
                if let data = snapshot.value as? NSDictionary {
                    if let senderID = data[DBConstants.SENDER_ID] as? String, let senderName = data[DBConstants.SENDER_NAME] as? String, let receiverID = data[DBConstants.RECEIVER_ID] as? String, let text = data[DBConstants.TEXT] as? String {
                        if let user = self.selectedUser {
                        if (receiverID == user) || (senderID == user) {
                            self.addMessage(senderID: senderID, receiverID: receiverID, senderName: senderName, text: text)
                            self.finishReceivingMessage()
                       }
                        }
                    }
                } else {
                    print("Error! Could not decode message data!")
                }
            })
        }
    }
    
   /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNavigationController = segue.destination as! UINavigationController
        let targetController = destinationNavigationController.topViewController
        if let userVC = targetController as? ChatViewController {
            userVC.selectedUser = self.receiverID
        }
        
    }*/

    @IBAction func backButtonChatWindow(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
   
}
