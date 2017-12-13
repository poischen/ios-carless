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
    func mediaReceived(senderID: String, senderName: String, url: String);
}

class MessageHandler {
    static let _shared = MessageHandler()
    private init() {}
    
    weak var delegate: MessageReceivedDelegate?;
    
    func sendMessage(senderID: String, senderName: String, text: String){
        
        let data: Dictionary<String, Any> = [Constants.SENDER_ID: senderID, Constants.SENDER_NAME: senderName, Constants.TEXT: text];
        
        StorageAPI.shared.messagesRef.childByAutoId().setValue(data);
    }
    
    func sendMediaMessage(senderID: String, senderName: String, url: String) {
        let data: Dictionary<String, Any> = [Constants.SENDER_ID: senderID, Constants.SENDER_NAME: senderName, Constants.URL: url];
        
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
    
    func observeMediaMessages() {
        
        StorageAPI.shared.mediaMessagesRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let id = data[Constants.SENDER_ID] as? String {
                    if let name = data[Constants.SENDER_NAME] as?
                        String {
                        if let fileURL = data[Constants.URL] as?
                        String {
                            self.delegate?.mediaReceived(senderID: id, senderName: name, url: fileURL);
                        }
                    }
                }
            }
        }
    }
}
