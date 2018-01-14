//
//  MessageHandler.swift
//  ios
//
//  Created by Jelena Pranjic on 09.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation
//import Firebase
//import FirebaseDatabase
//import FirebaseStorage

/*protocol AddMessageDelegate: class {
    func addMessage(senderID: String, receiverID: String, senderName: String, text: String)
}*/

class MessageHandler {
    
    static let shared = MessageHandler()
    
    //weak var delegate: AddMessageDelegate?
   
    /* fanning out of messages,
     sort messages by User IDs in "user-messages" node */
    func handleSend(senderID: String, receiverID: String, senderName: String, text: String) {
        let ref = StorageAPI.shared.messagesRef
        let values = [DBConstants.SENDER_ID: senderID, DBConstants.RECEIVER_ID: receiverID, DBConstants.SENDER_NAME: senderName, DBConstants.TEXT: text]
        
        ref.childByAutoId().updateChildValues(values){ (error, ref) in
            if error != nil {
                print("Oops something went wrong")
                return
            }
            //add new node "user-messages"
            let userMessagesRef = StorageAPI.shared.userMessagesRef.child(StorageAPI.shared.userID())
            
            //gets key of messages
            let messageID = ref.key
            userMessagesRef.updateChildValues([messageID: 1])
            
            let receiverUserMessageRef = StorageAPI.shared.userMessagesRef.child(receiverID)
            receiverUserMessageRef.updateChildValues([messageID: 1])
        }
        
        
        
    }
    
  
    
}
