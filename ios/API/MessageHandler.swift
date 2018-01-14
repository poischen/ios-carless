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


class MessageHandler {
    
    static let shared = MessageHandler()
   
    func handleSend(senderID: String, receiverID: String, senderName: String, text: String) {
        let ref = StorageAPI.shared.messagesRef
        let childRef = ref.childByAutoId()
        let values = [DBConstants.SENDER_ID: senderID, DBConstants.RECEIVER_ID: receiverID, DBConstants.SENDER_NAME: senderName, DBConstants.TEXT: text]
        childRef.updateChildValues(values)
        
    }
    
}
