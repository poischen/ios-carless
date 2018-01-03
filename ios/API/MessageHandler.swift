//
//  MessageHandler.swift
//  ios
//
//  Created by Jelena Pranjic on 09.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

protocol MessageReceivedDelegate: class {
    func messageReceived(senderID: String, receiverID: String, text: String);
    func mediaReceived(senderID: String, senderName: String, url: String);
}

class MessageHandler {
    static let _shared = MessageHandler()
    private init() {}
    
    weak var delegate: MessageReceivedDelegate?
    
    func sendMessage(senderID: String, senderName: String, text: String, receiverID: String){
        
        let data: Dictionary<String, Any> = [DBConstants.SENDER_ID: senderID, DBConstants.SENDER_NAME: senderName, DBConstants.TEXT: text, DBConstants.RECEIVER_ID: receiverID];
        
        //StorageAPI.shared.messagesRef.childByAutoId().setValue(data);
        
        let ref = StorageAPI.shared.messagesRef
        
        ref.childByAutoId().updateChildValues(data) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            let userMessagesRef = Database.database().reference().child("user-messages").child(StorageAPI.shared.userID())
            
            let messageID = ref.key
            userMessagesRef.updateChildValues([messageID: 1])
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(receiverID)
            recipientUserMessageRef.updateChildValues([messageID: 1])
        }
    }
    
    func sendMediaMessage(senderID: String, senderName: String, url: String) {
        let data: Dictionary<String, Any> = [DBConstants.SENDER_ID: senderID, DBConstants.SENDER_NAME: senderName, DBConstants.URL: url];
        
        StorageAPI.shared.mediaMessagesRef.childByAutoId().setValue(data);
    }
    
    func sendMedia(image: Data?, video: URL?, senderID: String, senderName: String) {
        
        if image != nil {
            
            StorageAPI.shared.imageStorageRef.child(senderID + "\(NSUUID().uuidString).jpg").putData(image!, metadata: nil) { (metadata: StorageMetadata?, err: Error?) in
                
                if err != nil {
                    //TODO: inform user if image wasn't uploaded
                    
                } else {
                  self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String (describing: metadata!.downloadURL()!));
                }
            }
            
                } else {
            StorageAPI.shared.videoStorageRef.child(senderID + "\(NSUUID().uuidString)").putFile(from: video!, metadata: nil) { (metadata: StorageMetadata?, err: Error?) in
                
                if err != nil {
                    //TODO: inform user if video wasn't uploaded
                    
                } else {
                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String (describing: metadata!.downloadURL()!));
                }
            }
            
        }
    }
    
    /*if let data = snapshot.value as? NSDictionary {
        if let senderID = data[DBConstants.SENDER_ID] as? String{
            if let receiverID = data[DBConstants.RECEIVER_ID] as? String {
                if let text = data[DBConstants.TEXT] as? String {
                    self.delegate?.messageReceived(senderID: senderID, receiverID: receiverID, text: text)
                }
            }
        }
    }*/
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            let messageID = snapshot.key
            let messagesRef = StorageAPI.shared.messagesRef.child(messageID)
            
            messagesRef.observeSingleEvent(of: .value, with: { snapshot in
                if let data = snapshot.value as? NSDictionary {
                    if let senderID = data[DBConstants.SENDER_ID] as? String{
                        if let receiverID = data[DBConstants.RECEIVER_ID] as? String {
                            if let text = data[DBConstants.TEXT] as? String {
                                self.delegate?.messageReceived(senderID: senderID, receiverID: receiverID, text: text)
                            }
                        }
                    }
                }
            })
            
        }
    }
    
    func observeMessages() {
        StorageAPI.shared.messagesRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
           /* if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message()
                message.setValuesForKeys(dictionary)
                self.messages.append(message)
            }*/
            
           if let data = snapshot.value as? NSDictionary {
                if let senderID = data[DBConstants.SENDER_ID] as? String{
                    if let receiverID = data[DBConstants.RECEIVER_ID] as? String {
                    if let text = data[DBConstants.TEXT] as? String {
                        self.delegate?.messageReceived(senderID: senderID, receiverID: receiverID, text: text)
                    }
                  }
                }
            }
        }
    }
    
    func observeMediaMessages() {
        
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
    }
    

    
}
