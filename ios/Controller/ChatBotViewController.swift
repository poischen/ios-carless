//
//  ChatBotViewController.swift
//  ios
//
//  Created by Hila Safi on 09.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import AVFoundation
import ApiAI

class ChatBotViewController: UIViewController {

    
    @IBOutlet weak var chipResponse: UILabel!
   
    @IBOutlet weak var messageField: UITextField!
    
    @IBAction func sendToBot(_ sender: Any) {
       let request = ApiAI.shared().textRequest()
        
        if let text = self.messageField.text, text != "" {
            request?.query = text
        } else {
            return
        }
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            if let textResponse = response.result.fulfillment.speech {
                self.speechAndText(text: textResponse)
            }
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
        messageField.text = ""
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    func speechAndText(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speak(speechUtterance)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.chipResponse.text = text
        }, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
