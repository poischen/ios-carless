//
//  MessageHandler.swift
//  ios
//
//  Created by Jelena Pranjic on 09.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation
import SDWebImage
import Photos

class MessageHandler {
    
    static let _shared = MessageHandler()
    static let defaultUserButtlerJamesID = "YouicSlsCSepkKJ27R0HN4buWCZ2"
    static let defaultUserButtlerJamesName = "Geoffrey"
    static let DEFAULT_MESSAGE_RENTING_REQUEST = "Hi! You have a new request for one of your offers. How exciting! Go to your home page and have a look!"
    static let DEFAULT_MESSAGE_RENTING_REQUEST_ACCEPTED = "Hi! The lessor has accepted your request. Visit your home page for details."
    static let DEFAULT_MESSAGE_RENTING_REQUEST_DENIED = "Hi! The lessor has denied your request. Sorry :("
    
    private init() {}
    
    static let shared = MessageHandler()
   
    /* fanning out of messages,
     sort messages by User IDs in "user-messages" node */
    func handleSend(senderID: String, receiverID: String, text: String) {
            let ref = StorageAPI.shared.messagesRef
            
            let values = [DBConstants.SENDER_ID: senderID, DBConstants.RECEIVER_ID: receiverID, DBConstants.TEXT: text]
            
            ref.childByAutoId().updateChildValues(values){ (error, ref) in
                if error != nil {
                    print("Oops something went wrong")
                    return
                }
                //add new node "user-messages"
                let userMessagesRef = StorageAPI.shared.userMessagesRef.child(senderID)
                
                //gets key of messages
                let messageID = ref.key
                userMessagesRef.updateChildValues([messageID: 1])
                
                let receiverUserMessageRef = StorageAPI.shared.userMessagesRef.child(receiverID)
                receiverUserMessageRef.updateChildValues([messageID: 1])
            }
       
    }
    
    func uploadImageToFirebase(senderID: String, receiverID: String, image: UIImage) {
        let imageName = NSUUID().uuidString
        let ref = StorageAPI.shared.imageStorageRef.child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.01) {
            ref.putData(uploadData, metadata: nil, completion: {(metadata, error) in
                if error != nil {
                    print("Failed to upload image!")
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithUrl(senderID: senderID, receiverID: receiverID, url: imageUrl)
                }
                
            })
        }
    }
    
    func uploadVideoToFirebase(senderID: String, receiverID: String, vidUrl: URL?) {
        let fileName = NSUUID().uuidString
        StorageAPI.shared.videoStorageRef.child(fileName).putFile(from: vidUrl!, metadata: nil) { (metadata, error) in
            
            if error != nil {
                print("Failed to upload video!")
                return
            }
            
            if let vidUrl = metadata?.downloadURL()?.absoluteString {
                self.sendMessageWithUrl(senderID: senderID, receiverID: receiverID, url: vidUrl)
            }
        }
    }
    
    func sendMessageWithUrl(senderID: String, receiverID: String, url: String) {
        if let currentUserID = StorageAPI.shared.userID() {
            let ref = StorageAPI.shared.messagesRef
            
            let values = [DBConstants.SENDER_ID: senderID, DBConstants.RECEIVER_ID: receiverID, DBConstants.URL: url]
            
            ref.childByAutoId().updateChildValues(values){ (error, ref) in
                if error != nil {
                    print("Oops something went wrong")
                    return
                }
                //add new node "user-messages"
                let userMessagesRef = StorageAPI.shared.userMessagesRef.child(currentUserID)
                
                //gets key of messages
                let messageID = ref.key
                userMessagesRef.updateChildValues([messageID: 1])
                
                let receiverUserMessageRef = StorageAPI.shared.userMessagesRef.child(receiverID)
                receiverUserMessageRef.updateChildValues([messageID: 1])
            }
        }
        
    }

}
