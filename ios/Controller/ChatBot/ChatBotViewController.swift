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

class ChatBotViewController: UIViewController, UITextFieldDelegate {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chipResponse.numberOfLines = 0;
        print ("Possible Speech Voices" , AVSpeechSynthesisVoice.speechVoices())
        messageField.delegate = self
    }
    
   
    
    
    
    var geocountrylocal: String? = nil
    var consultlocal: String? = nil
    
   
    
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
                        if let textResponse = response.result.fulfillment.speech {
                            self.speechAndText(text: textResponse)
                            return
                        } else {
                            return
                        }
                }

                if (geocountry != "" && consult != "") { //alles ist da
                    if let textResponse = response.result.fulfillment.speech {
                        self.speechAndText(text: textResponse)
                        self.geocountrylocal = geocountry
                        self.consultlocal = consult
                        
                        
                        
                    }
                } else if (geocountry == "" && consult != "") { // Country nicht gegeben ...
                    if (self.geocountrylocal != nil) { // ... aber gespeichert
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
                        if let textResponse = response.result.fulfillment.speech {
                            self.speechAndText(text: textResponse)
                        }
                    }
                } else if (geocountry != "" && consult == "") { //consults nicht gegeben
                    if (self.consultlocal != nil) { // ... aber gespeichert
                        print ("im here")
                        print (self.consultlocal)
                        let requestconsult = ApiAI.shared().textRequest()
                        requestconsult?.query = self.consultlocal!
                        
                        
                        requestconsult?.setMappedCompletionBlockSuccess({ (request, response) in
                            guard  let response = response as? AIResponse,
                                let parameters = response.result.parameters as? [String: AIResponseParameter],
                                let geocountry = parameters["geo-country"]?.stringValue else {
                                    return
                            }
                            self.geocountrylocal = geocountry
                            
                            if let textResponse = response.result.fulfillment.speech {
                                self.speechAndText(text: textResponse)
                                
                            }
                            
                        }, failure: { (request, error) in
                            print(error!)
                        })
                        ApiAI.shared().enqueue(requestconsult)
                    }else { // consult nicht gegeben und nicht gespeichert
                        if let textResponse = response.result.fulfillment.speech {
                            self.speechAndText(text: textResponse)
                        }
                    }
                }
                    
                
            }
          
            
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
        messageField.text = ""
    }
    
    
    let speechSynthesizer = AVSpeechSynthesizer()
  
    

    func speechAndText(text: String) {
        let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Daniel-compact")
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = voice
        speechSynthesizer.speak(speechUtterance)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.chipResponse.text = text
        }, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.view.endEditing(true)
        
        return true
        
    }

  
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    
    
    
}
