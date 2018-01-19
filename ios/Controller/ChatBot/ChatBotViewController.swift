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

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chipResponse.numberOfLines = 0;
    }
    
    var geocountrylocal: String? = ""
    var consultlocal: String? = ""
    
    
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
            
            if let parameters = response.result.parameters as? [String: AIResponseParameter] {
                guard let geocountry = parameters["geo-country"]?.stringValue,
                    let consult = parameters["consults"]?.stringValue else {
                        return
                }
                if (geocountry != "" && consult != "") {
                    if let textResponse = response.result.fulfillment.speech {
                        self.speechAndText(text: textResponse)
                        self.geocountrylocal = geocountry
                        self.consultlocal = consult
                    }
                } else if (geocountry == "" && consult != "") { // Country nicht gegeben ...
                    if (self.geocountrylocal != "") { // ... aber gespeichert
                        let requestcountry = ApiAI.shared().textRequest()
                        requestcountry?.query = self.geocountrylocal!
                    
                        
                        requestcountry?.setMappedCompletionBlockSuccess({ (request, response) in
                            guard  let response = response as? AIResponse,
                                let parameters = response.result.parameters as? [String: AIResponseParameter],
                                let consult = parameters["consults"]?.stringValue else {
                                    return
                                }
                            self.consultlocal = consult
                            
                            if let textResponse = response.result.fulfillment.speech {
                                self.speechAndText(text: textResponse)
                                
                            }
                            
                        }, failure: { (request, error) in
                            print(error!)
                        })
                        ApiAI.shared().enqueue(requestcountry)
                    } else { // Country nicht gegeben und nicht gespeichert
                        
                    }
                }
            }
          
            
            
            
            if let textResponse = response.result.fulfillment.speech {
               self.speechAndText(text: textResponse)
            }
            
            
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
        messageField.text = ""
    }
    
    /*      if let textResponse = response.result.fulfillment.speech {
     if let parameters = response.result.parameters as? [String: AIResponseParameter]{
     if let geocountry = parameters["geo-country"]?.stringValue, let cousult = parameters ["consults"]?.stringValue {
     if (geocountry == "") && (consult == "") {
     self.speechAndText(text: textResponse)
     } else if (geocountry == "") && (consult != "") {
     if (geocountylocal != nil) {*/
    
    /*  if let parameters = response.result.parameters as? [String: AIResponseParameter] {
     if let geocountry = parameters["geo-country"]?.stringValue {
     switch geocountry {
     case "Germany":
     print ("it was germany")
     default:
     print ("didnt get the value")
     }
     }
     }*/
    
    
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
