//
//  RateViewController.swift
//  ios
//
//  Created by Konrad Fischer on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//
/*
 How to use this class:
 - set retingBeingRated before showing the rating view
 - set rateLessee to false if a lessor should be rated
 - if a lessee should be rated: set userBeingRated to the lessee's user
 */

import UIKit
import Cosmos

class RateViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var ratingExplanation: UITextView!
    @IBOutlet weak var ratingCarModel: UILabel!
    @IBOutlet weak var userBeingRatedUsernameLabel: UILabel!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var ratingStarsView: CosmosView!
    private let MIN_EXPLANATION_LENGTH = 50
    private let MAX_EXPLANATION_LENGTH = 300
    private let CHARACTER_COUNT_LABEL_LIMIT = "/50"
    
    var rentingBeingRated: Renting?
    var userBeingRated: User?
    // If a leesor should be rated additional information is necessary (default: true)
    var ratingLessee: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ratingExplanation.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ratingLessee {
            if let currentRentingBeingRated = rentingBeingRated, let currentUserBeingRated = userBeingRated {
                // lessee should be rated and we already have the lessee's user -> get car model name (as we already have the user)
                RateModel.getCarModelName(rentingBeingRated: currentRentingBeingRated, completion: {carModelName in
                    self.initView(carModelName: carModelName, username: currentUserBeingRated.name)
                })
            }
        } else {
            if let currentRentingBeingRated = rentingBeingRated {
                // lessor should be rated and we have the renting that should be rated -> get lessor's user and car model name from DB
                RateModel.getAdditionalInformationForLessorRating(rentingBeingRated: currentRentingBeingRated, completion: {(carModelName, lessorUser) in
                    self.initView(carModelName: carModelName, username: lessorUser.name)
                    self.userBeingRated = lessorUser
                })
            }
        }
    }
    
    // initialise view
    func initView(carModelName: String, username: String) {
        self.ratingCarModel.text = carModelName
        self.userBeingRatedUsernameLabel.text = username
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        // update character count label
        characterCountLabel.text = String(numberOfChars) + CHARACTER_COUNT_LABEL_LIMIT
        
        // prevent further typing if the max explanation limit is reached
        return numberOfChars < MAX_EXPLANATION_LENGTH
    }

    @IBAction func saveRatingButtonClicked(_ sender: Any) {
        if userBeingRated != nil {
            // checking whether the explanation has the right length (although it shouldn't be possible to enter one that's too long)
            if ratingExplanation.text.count >= MIN_EXPLANATION_LENGTH && ratingExplanation.text.count <= MAX_EXPLANATION_LENGTH {
                if let currentRentingBeingRated = rentingBeingRated {
                    // save rating, update user's average rating and go back to the profile
                    RateModel.saveRating(rating: Int(ratingStarsView.rating), ratedUser: userBeingRated!, explanation: ratingExplanation.text, renting: currentRentingBeingRated, ratingLessee: ratingLessee)
                    goBackToProfile()
                }
            } else {
                // explanation doesn't have the right length -> prepare alert with error message and show it
                let alertController = UIAlertController(title: "Sorry", message: "Your explanation is too long or too short. :(", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "back", style: .cancel, handler: {alterAction in
                    self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    private func goBackToProfile(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        goBackToProfile()
    }
    
    
}
