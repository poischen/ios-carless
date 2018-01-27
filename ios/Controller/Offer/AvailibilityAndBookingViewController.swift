//
//  AvailibilityAndBookingViewController.swift
//  ios
//
//  Created by admin on 11.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import JTAppleCalendar

class AvailibilityAndBookingViewController: UIViewController {
    
    var pageViewController: AdvertisePagesVC!
    let storageAPI = StorageAPI.shared
    var offer: Offering?
    
    var preselectedEndDate: Date?
    var preselectedStartDate: Date?
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthAndYear: UILabel!
    @IBOutlet weak var resultView: UILabel!
    @IBOutlet weak var reservationButton: UIButton!
    @IBOutlet weak var priceView: UILabel!
    @IBOutlet weak var ratingDiscountView: UILabel!
    @IBOutlet weak var experienceDiscountView: UILabel!
    @IBOutlet weak var totalPriceView: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var hiddenElementsView: UIStackView!

    let formatter = DateFormatter()
    var firstDate: Date?
    var lastDate: Date?
    var recursiveSelectionCall = false
    var recursiveDeselectionCall = false
    let notInMonthColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 0.5)
    
    var dates2Check: [Date] = []
    var totalPrice: Float = 0
    
    let TITLE_OWN = "Check Availibility Preview"
    let TITLE = "Check Availibility"
    let RESULT_POSITIVE = "Yey, the car is availible!"
    let RESULT_NEGATIVE = "Not availible - try another date! :)"
    let NO_RATING_DISC = "  0 (% from 4,5 *)"
    let RATING_35 = " (+ 20 % fee)"
    let RATING_45 = " (- 5 %)"
    let RATING_5 = " (- 10 %)"
    let RATING_QUOT_35: Float = -0.2
    let RATING_QUOT_45: Float = 0.05
    let RATING_QUOT_5: Float = 0.1
    let NO_EXP_DISC = "  0 (1% à 10 ratings)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        indicator.stopAnimating()
        hiddenElementsView.isHidden = true
        
        if (storageAPI.userID() == offer!.userUID) {
            self.navigationItem.title = TITLE_OWN
            reservationButton.isHidden = true
        } else {
            self.navigationItem.title = TITLE
            reservationButton.isEnabled = false
        }
        
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        
        calendarView.allowsMultipleSelection  = true
      //  calendarView.isRangeSelectionUsed = true
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
       if let psd = preselectedStartDate, let ped = preselectedEndDate {
            calendarView.scrollToHeaderForDate(psd)
            calendarView.scrollToDate(psd)
            firstDate = psd
            let preselectionEndDate: [Date] = [ped]
            calendarView.selectDates(preselectionEndDate)
        }
        
        calendarView.visibleDates { visibleDates in
            self.setupMonthYear(from: visibleDates)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleSelectionVisually(view: JTAppleCell?, cellState: CellState){
        guard let cell = view as? AvailibilityCalendarCell else {return}
      
        
        switch cellState.selectedPosition() {
        case .full, .middle, .left, .right:
            cell.cellSelectionFeedback.isHidden = false
            cell.cellSelectionFeedback.layer.cornerRadius = 25
            
        default:
            cell.cellSelectionFeedback.isHidden = true
        }
        
      /*  switch cellState.selectedPosition() {
        case .full:
            cell.cellSelectionFeedback.isHidden = false
            cell.availibility.isBlocked = false
            cell.cellSelectionFeedback.clipsToBounds = true
            cell.cellSelectionFeedback.layer.cornerRadius = 15
            print("full")
            
        case .middle:
            cell.cellSelectionFeedback.isHidden = false
            cell.availibility.isBlocked = false
            print("middle")
        
        case .right:
            cell.cellSelectionFeedback.isHidden = false
            cell.availibility.isBlocked = false
            cell.cellSelectionFeedback.clipsToBounds = true
            cell.cellSelectionFeedback.layer.cornerRadius = 15
            cell.cellSelectionFeedback.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            print("right")
        
        case .left:
            cell.cellSelectionFeedback.isHidden = false
            cell.availibility.isBlocked = false
            cell.cellSelectionFeedback.clipsToBounds = true
            cell.cellSelectionFeedback.layer.cornerRadius = 15
            cell.cellSelectionFeedback.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            print("left")

        default:
            cell.cellSelectionFeedback.isHidden = true
            cell.availibility.isBlocked = true
        }*/
    }
    
    func handleMonthColors(view: JTAppleCell?, cellState: CellState){
        guard let cell = view as? AvailibilityCalendarCell else {return}
        
        if cellState.dateBelongsTo == .thisMonth {
            }
        else {
            cell.dateLabel.textColor = notInMonthColor
        }
    }
    
    func setupMonthYear(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "MMMM yy"
        monthAndYear.text = formatter.string(from: date)
    }

    func checkAvailibility() -> Void {
        self.reservationButton.isEnabled = false
        self.indicator.startAnimating()
        self.hiddenElementsView.isHidden = true
        
        var intervall2Check: DateInterval?
        
        if (lastDate != nil){
            intervall2Check = DateInterval(start: firstDate!, end: lastDate!)
        } else {
            intervall2Check = DateInterval(start: firstDate!, end: firstDate!)
        }
        
        storageAPI.getRentings(completion: { (rentings) in
            //check dates from rentings
            for renting in rentings {
                if (renting.confirmationStatus){
                let rentingIntervall = DateInterval(start: renting.startDate, end: renting.endDate)
                if (intervall2Check?.intersects(rentingIntervall))!{
                    self.resultView.text = self.RESULT_NEGATIVE
                    self.indicator.stopAnimating()
                    return
                }
            }
            }
            //if renting-check was okay, check blocked days:
            //storage api get blocked dates id
            if let oid = self.offer!.id {
                self.storageAPI.getBlockedDaysIDByOfferingID(offeringID: oid, completion: { (blockedDaysID) in
                    //storage api get blocked dates
                    self.storageAPI.getBlockedDaysByID(bdID: blockedDaysID, completion: { (blockDaysInts) in
                        //check blocked days
                        for day in blockDaysInts {
                            let date = Renting.intTimestampToDate(timestamp: day)
                            let blockedDateIntervall = DateInterval(start: date, end: date)
                            if (intervall2Check?.intersects(blockedDateIntervall))!{
                                self.resultView.text = self.RESULT_NEGATIVE
                                self.indicator.stopAnimating()
                                return
                            }
                        }
                    })
                })
            }
        })
        
        self.resultView.text = RESULT_POSITIVE
        calculatePrice(rentingIntervall: intervall2Check!)
    }
    
    func calculatePrice(rentingIntervall: DateInterval) -> Void {
        let userID = storageAPI.userID()
        //calculate discount depending on rating
        storageAPI.getUserByUID(UID: userID) { (user) in
            let intervalLengthInt = (Calendar.current.dateComponents([.day], from: rentingIntervall.start, to: rentingIntervall.end).day!) + 1
            let intervalLength : Float = Float(intervalLengthInt)
            let priceperDay: Float = Float((self.offer!.basePrice))
            
            self.priceView.text = "  \(priceperDay)"
            let ratingAverageValue: Float = user.rating
            var ratingDiscount: Float = 0
            var expDiscount: Float = 0
            
            let ratings = user.numberOfRatings
                //discount for average rating value & for experience measured by ammount of ratings
                if ratings > 0 {
                    if (ratingAverageValue >= 4.9) { //get 10% discount
                        ratingDiscount = priceperDay*self.RATING_QUOT_5
                        self.ratingDiscountView.text = "- \(ratingDiscount)" + self.RATING_5
                    } else if (ratingAverageValue >= 4.5 && ratingAverageValue < 4.9) { //get 5% discount
                        ratingDiscount = priceperDay * self.RATING_QUOT_45
                        self.ratingDiscountView.text = "- \(ratingDiscount)" + self.RATING_45
                    } else if (ratingAverageValue < 4.5 && ratingAverageValue >= 3.5) { //get nothing
                        self.ratingDiscountView.text = self.NO_RATING_DISC
                    } else if (ratingAverageValue < 3.5) { //get 20% fee
                        ratingDiscount = priceperDay * self.RATING_QUOT_35
                        self.ratingDiscountView.text = "+ \(ratingDiscount*(-1))" + self.RATING_35
                    }
                    let expDiscountPercent = (ratings - (ratings % 10)) / 10
                    if expDiscount >= 1 {
                        expDiscount = (priceperDay * Float(expDiscountPercent))/100
                        self.experienceDiscountView.text = "-  \(expDiscount) (- \(expDiscountPercent) %)"
                    } else {
                        self.experienceDiscountView.text = self.NO_EXP_DISC
                    }
                } else {
                    self.ratingDiscountView.text = self.NO_RATING_DISC
                }
                self.totalPrice = ((priceperDay - ratingDiscount - expDiscount) * intervalLength)
                self.totalPriceView.text = "\(self.totalPrice)"
                
                if (intervalLengthInt > 1) {
                    self.totalPriceLabel.text = "\(intervalLengthInt) days total price:"
                } else {
                    self.totalPriceLabel.text = "\(intervalLengthInt) day total price:"
                }
        }
        
        
        
        self.reservationButton.isEnabled = true
        self.indicator.stopAnimating()
        self.hiddenElementsView.isHidden = false
    }
    
    @IBAction func reserve(_ sender: Any) {
        reservationButton.isEnabled = false
        indicator.startAnimating()
        storageAPI.generateRentingKey(completion: {(rentingID) in
            let renting = Renting(id: rentingID, inseratID: self.offer!.id!, userID: self.storageAPI.userID(), startDate: self.firstDate!, endDate: self.lastDate!, confirmationStatus: false, rentingPrice: self.totalPrice, lessorRated: false, lesseeRated: false)
            self.storageAPI.saveRenting(renting: renting, completion: { (statusMessage) in
                if (statusMessage == StorageAPI.STORAGE_API_SUCCESS) {
                    MessageHandler.shared.handleSend(senderID: MessageHandler.defaultUserButtlerJamesID, receiverID: self.offer!.id!, text: MessageHandler.DEFAULT_MESSAGE_RENTING_REQUEST + " " + self.offer!.type + " for " + "\(self.totalPrice)" + " €")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.reservationButton.isEnabled = true
                    self.resultView.text = ""
                    self.hiddenElementsView.isHidden = true
                    let alertMissingInputs = UIAlertController(title: "Something went wrong", message: "Please try again later.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
                    alertMissingInputs.addAction(ok)
                    self.present(alertMissingInputs, animated: true, completion: nil)
                }
            })

        })
    }

}

extension AvailibilityAndBookingViewController: JTAppleCalendarViewDelegate {
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! AvailibilityCalendarCell
        let availibility = Availibility(date: date)
        cell.availibility = availibility
        cell.dateLabel.text = cellState.text
        handleMonthColors(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: "availibilityCalendarCell", for: indexPath) as! AvailibilityCalendarCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
   /* func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let selectedDate = cell as? AvailibilityCalendarCell else {return}
        if firstDate != nil {
            calendarView.selectDates(from: firstDate!, to: date,  triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: true)
        } else {
            firstDate = date
        }
        handleSelectionVisually(view: selectedDate, cellState: cellState)
    }*/
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? AvailibilityCalendarCell else {return}
        handleSelectionVisually(view: cell, cellState: cellState)
        if recursiveSelectionCall == false { // ... but only examine whether a recursive call is necessary when this isn't already a recursive cell
            if let currentFirstDate = firstDate {
                // first date set
                if lastDate != nil {
                    // date range already set -> remove and set new first date
                    calendarView.deselectDates(from: currentFirstDate, to: currentFirstDate, triggerSelectionDelegate: true)
                    firstDate = date
                    lastDate = nil
                } else {
                    // first date set, last date not set
                    if (date < currentFirstDate){
                        /* new date is before first date -> remove first date and set current date as new first date
                         first deselect current date interval
                         deselecting one date is enough as the shouldDeselect function ensures that when one date from the current date interval is deselected all others are also */
                        recursiveDeselectionCall = true
                        calendarView.deselectDates(from: firstDate!, to: firstDate!, triggerSelectionDelegate: true)
                        recursiveDeselectionCall = false
                        firstDate = date // deselection resets first date -> set after deselection
                        lastDate = nil // for safety :)
                    } else {
                        // new date is on or after first date -> set last date
                        lastDate = date
                        if (firstDate != lastDate) {
                            // first date and last date are not on the same day -> select cells in between
                            recursiveSelectionCall = true // prevent endless recursion
                            calendarView.selectDates(from: currentFirstDate, to: date,  triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: true)
                            recursiveSelectionCall = false
                        }
                    }
                }
            } else {
                // first date not set yet -> set first date
                firstDate = date
            }
        }
        checkAvailibility()
    }
    
   /* func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
            guard let releasedDate = cell as? AvailibilityCalendarCell else {return}
        firstDate = nil
        if calendarView.selectedDates.count > 1 {
            calendarView.deselectAllDates()
        }
            handleSelectionVisually(view: releasedDate, cellState: cellState)
    }*/
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? AvailibilityCalendarCell else {return}
        handleSelectionVisually(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupMonthYear(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        // this function ensures that when one date from the current date interval is deselected all others are too
        // -> deselecting one date from the current date interval is sufficient
        if recursiveDeselectionCall == true {
            // this is a reursive call -> only deselect cell and don't start a new recursive call
            return true
        } else {
            if let currentFistDate = firstDate, let currentLastDate = lastDate {
                // deselect current date interval
                recursiveDeselectionCall = true // prevent endless recursion
                calendarView.deselectDates(from: currentFistDate, to: currentLastDate, triggerSelectionDelegate: true)
                recursiveDeselectionCall = false
                // unset first date and last date
                firstDate = nil
                lastDate = nil
                hiddenElementsView.isHidden = true
                reservationButton.isEnabled = false
            }
            return false
        }
    }


}

extension AvailibilityAndBookingViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let endDate = Date() + 31104000 // one year from now
        let parameters = ConfigurationParameters(
            startDate: Date(),
            endDate: endDate,
            numberOfRows: 6,
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .monday
        )
        return parameters
    }
}
