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
 - set rateLessee to true before showing the view in case the view should be used to rate a lessee
 */

import UIKit

class RateViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var ratingExplanation: UITextView!
    @IBOutlet weak var ratingStars: RateStarControl!
    @IBOutlet weak var ratingCarModel: UILabel!
    @IBOutlet weak var ratingLessorUsername: UILabel!
    
    private let minExplanationLength = 50
    private let maxExplanationLength = 300
    
    var rentingBeingRated: Renting? = Renting(id: "1", inseratID: "1", userID: "W7VPwDFSTyNwW0WJl38MhsVmcdX2", startDate: Date(), endDate: Date()) // TODO: set from profile, only here for testing
    private var userBeingRated: User? = nil // TODO: set from profile
    var rateLessee: Bool = true // should the view to rate a lessee be shown (default: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ratingExplanation.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (rentingBeingRated != nil){
            if (rateLessee){
                RateModel.getAdditionalInformationForLesseeRating(rentingBeingRated: rentingBeingRated!, completion: { (carModelName, lesseeUser) in
                    self.ratingCarModel.text = carModelName
                    self.ratingLessorUsername.text = lesseeUser.name
                    self.userBeingRated = lesseeUser
                })
            } else {
                // rate a lessor
                RateModel.getAdditionalInformationForLessorRating(rentingBeingRated: rentingBeingRated!, completion: { (carModelName, lessorUser) in
                    self.ratingCarModel.text = carModelName
                    self.ratingLessorUsername.text = lessorUser.name
                    self.userBeingRated = lessorUser
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < maxExplanationLength
    }

    @IBAction func saveRatingButtonClicked(_ sender: Any) {
        if userBeingRated != nil {
            // checking whether the explanation has the right length (although it shouldn't be possible to enter one that's too long)
            if ratingExplanation.text.count >= minExplanationLength && ratingExplanation.text.count <= maxExplanationLength {
                // save rating and update user's average rating
                RateModel.saveRating(rating: ratingStars.rating, ratedUser: userBeingRated!, explanation: ratingExplanation.text)
                goBackToProfile()
            } else {
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
    
    private func goBackToProfile(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Home")
        self.present(vc, animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
