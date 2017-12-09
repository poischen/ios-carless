//
//  MessageHandler.swift
//  ios
//
//  Created by Jelena Pranjic on 09.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import Foundation

class MessageHandler {
    static let _shared = MessageHandler()
    private init() {}
    
    func sendMessage(senderID: String, senderName: String, text: String){
        
        let data: Dictionary<String, Any> = [Constants.SENDER_ID: senderID, Constants.SENDER_NAME: senderName, Constants.TEXT: text];
        
        StorageAPI.shared.messagesRef.childByAutoId().setValue(data);
    }
}
