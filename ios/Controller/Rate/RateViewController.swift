//
//  RateViewController.swift
//  ios
//
//  Created by Konrad Fischer on 28.12.17.
//  Copyright © 2017 Hila Safi. All rights reserved.
//

import UIKit

class RateViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var ratingExplanation: UITextView!
    @IBOutlet weak var ratingStars: RateStarControl!
    @IBOutlet weak var ratingCarModel: UILabel!
    @IBOutlet weak var ratingLessorUsername: UILabel!
    
    private let minExplanationLength = 100
    private let maxExplanationLength = 300
    
    let rentingBeingRated: Renting? = Renting(id: 1, inseratID: 1, userID: "b4nac5ozY7PPK61cRxRvtj2gCTH2", startDate: Date(), endDate: Date()) // TODO: use renting here?
    private var lessorUser: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ratingExplanation.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (rentingBeingRated != nil){
            RateModel.getRatingInformationFromDB(rentingBeingRated: rentingBeingRated!, completion: { (carModelName, lessorUser) in
                self.ratingCarModel.text = carModelName
                self.ratingLessorUsername.text = lessorUser.name
                self.lessorUser = lessorUser
            })
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
        if lessorUser != nil {
            // checking whether the explanation has the right length (although it shouldn't be possible to enter one that's too long)
            if ratingExplanation.text.count >= minExplanationLength && ratingExplanation.text.count <= maxExplanationLength {
                let newRating = LessorRating(id: 5, userUID: lessorUser!.id, explanation: ratingExplanation.text, rating: ratingStars.rating)
                StorageAPI.shared.saveLessorRating(rating: newRating)
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
