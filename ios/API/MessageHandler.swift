//
//  MessageHandler.swift
//  ios
//
//  Created by Jelena Pranjic on 09.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

protocol MessageReceivedDelegate: class {
    func messageReceived(senderID: String, text: String);
}

class MessageHandler {
    static let _shared = MessageHandler()
    private init() {}
    
    weak var delegate: MessageReceivedDelegate?;
    
    func sendMessage(senderID: String, senderName: String, text: String){
        
        let data: Dictionary<String, Any> = [Constants.SENDER_ID: senderID, Constants.SENDER_NAME: senderName, Constants.TEXT: text];
        
        StorageAPI.shared.messagesRef.childByAutoId().setValue(data);
    }
    
    func observeMessages() {
        StorageAPI.shared.messagesRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let senderID = data[Constants.SENDER_ID] as? String{
                    if let text = data[Constants.TEXT] as? String {
                        self.delegate?.messageReceived(senderID: senderID, text: text)
                    }
                }
            }
        }
    }
}
