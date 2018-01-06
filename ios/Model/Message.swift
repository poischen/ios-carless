//
//  Message.swift
//  ios
//
//  Created by Jelena Pranjic on 02.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var receiverID: String = ""
    var text: String = ""
    var senderID: String = ""
    var senderName: String = ""
    
    func chatPartnerID() -> String? {
        if senderID == Auth.auth().currentUser?.uid {
            return receiverID
        } else {
            return senderID
        }
    }
    
    /*init(senderID: String, senderName: String, receiverID: String, text: String) {
       self.senderID = senderID
        self.senderName = senderName
        self.receiverID = receiverID
        self.text = text
    }*/

}
