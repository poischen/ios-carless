//
//  AvailibilityAndBookingViewController.swift
//  ios
//
//  Created by admin on 11.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import JTAppleCalendar

class AvailibilityAndBookingViewController: UIViewController, UsingCalendar {
    
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
    let SUCCESS_MESSAGE_BOOKING = "The reservation was successful! Just wait for the lessors reply now :)"
    
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
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
       if let psd = preselectedStartDate, let ped = preselectedEndDate {
            calendarView.scrollToHeaderForDate(psd)
            calendarView.scrollToDate(psd)
            calendarView.selectDates(from: psd, to: ped)
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
            cell.cellSelectionFeedback.layer.cornerRadius = 15
            
        default:
            cell.cellSelectionFeedback.isHidden = true
        }
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
                    self.resultView.isHidden = false
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
                                self.resultView.isHidden = false
                                self.indicator.stopAnimating()
                                return
                            }
                        }
                    })
                })
            }
        })
        
        self.resultView.text = RESULT_POSITIVE
        self.resultView.isHidden = false
        calculatePrice(rentingIntervall: intervall2Check!)
    }
    
    func calculatePrice(rentingIntervall: DateInterval) -> Void {
        if let userID = storageAPI.userID() {
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
        //calculate discount depending on rating
        
    }
    
    @IBAction func reserve(_ sender: Any) {
        reservationButton.isEnabled = false
        indicator.startAnimating()
        storageAPI.generateRentingKey(completion: {(rentingID) in
            if let uid = self.storageAPI.userID(){
                guard let offering = self.offer, let offerID = offering.id, let firstDate = self.firstDate, let endDate = self.lastDate else {
                    self.failureFeedback()
                    return
                }
                let renting = Renting(id: rentingID, inseratID: offerID, userID: uid, startDate: firstDate, endDate: endDate, confirmationStatus: false, rentingPrice: self.totalPrice, lessorRated: false, lesseeRated: false)
                self.storageAPI.saveRenting(renting: renting, completion: { (statusMessage) in
                    if (statusMessage == StorageAPI.STORAGE_API_SUCCESS) {
                        MessageHandler.shared.handleSend(senderID: MessageHandler.defaultUserButtlerJamesID, receiverID: self.offer!.userUID, text: MessageHandler.DEFAULT_MESSAGE_RENTING_REQUEST + " " + self.offer!.type + " for " + "\(self.totalPrice)" + " €")
                        
                            let alert = UIAlertController(title: "Yey", message: self.SUCCESS_MESSAGE_BOOKING, preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: {
                            action in
                            self.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        
                    } else {
                        self.failureFeedback()
                    }
                })
            }
        })
    }
    
    func failureFeedback(){
        self.reservationButton.isEnabled = true
        self.resultView.text = ""
        self.hiddenElementsView.isHidden = true
        let alertMissingInputs = UIAlertController(title: "Something went wrong", message: "Please try again later.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
        alertMissingInputs.addAction(ok)
        self.present(alertMissingInputs, animated: true, completion: nil)
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

    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? AvailibilityCalendarCell else {return}
        handleSelectionVisually(view: cell, cellState: cellState)
        CalendarLogic.didSelectDate(usingCalendar: self, selectedDate: date)
        checkAvailibility()
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let cell = cell as? AvailibilityCalendarCell else {return}
        handleSelectionVisually(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        // prevent user from selecting dates in the past
        let now = Date()
        return date > now
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupMonthYear(from: visibleDates)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        return CalendarLogic.shouldDeselectDate(usingCalendar: self)
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
