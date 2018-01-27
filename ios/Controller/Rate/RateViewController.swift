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

class RateViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var ratingExplanation: UITextView!
    @IBOutlet weak var ratingStars: RateStarControl!
    @IBOutlet weak var ratingCarModel: UILabel!
    @IBOutlet weak var userBeingRatedUsernameLabel: UILabel!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    private let MIN_EXPLANATION_LENGTH = 50
    private let MAX_EXPLANATION_LENGTH = 300
    private let CHARACTER_COUNT_LABEL_LIMIT = "/50"
    
    //var rentingBeingRated: Renting? = Renting(id: "1", inseratID: "-L2GGCQf0M-9rPzx3Wx4", userID: "W7VPwDFSTyNwW0WJl38MhsVmcdX2", startDate: Date(), endDate: Date(), confirmationStatus: true, rentingPrice: 10.0) // TODO: set from profile, only here for testing
    
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
                // lessee should be rated and we already have the lessee's user -> get car model name
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
        
        return numberOfChars < MAX_EXPLANATION_LENGTH
    }

    @IBAction func saveRatingButtonClicked(_ sender: Any) {
        if userBeingRated != nil {
            // checking whether the explanation has the right length (although it shouldn't be possible to enter one that's too long)
            if ratingExplanation.text.count >= MIN_EXPLANATION_LENGTH && ratingExplanation.text.count <= MAX_EXPLANATION_LENGTH {
                if let currentRentingBeingRated = rentingBeingRated {
                    // save rating, update user's average rating and go back to the profile
                    RateModel.saveRating(rating: ratingStars.rating, ratedUser: userBeingRated!, explanation: ratingExplanation.text, renting: currentRentingBeingRated, ratingLessee: ratingLessee)
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
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        goBackToProfile()
    }
    
    // TODO: replace with navigation controller
    private func goBackToProfile(){
        /* let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Home")
        self.present(vc, animated: true, completion: nil)*/
        self.dismiss(animated: true, completion: nil)
    }
}
