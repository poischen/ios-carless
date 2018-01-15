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
    @IBOutlet weak var discountView: UILabel!
    @IBOutlet weak var totalPriceView: UILabel!
    
    let formatter = DateFormatter()
    var firstDate:Date?
    var lastDate:Date?
    var recursiveSelectionCall = false
    var recursiveDeselectionCall = false
    let selectedColor = UIColor(hue: 0.9917, saturation: 0.67, brightness: 0.75, alpha: 1.0)
    let releasedColor = UIColor(hue: 0, saturation: 0, brightness: 1, alpha: 1.0)
    let notInMonthColor = UIColor(hue: 0.7306, saturation: 0.07, brightness: 0.43, alpha: 1.0)
    
    var dates2Check: [Date] = []
    var totalPrice: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (storageAPI.userID() == offer!.userUID) {
            self.navigationItem.title = "Check Availibility Preview"
            reservationButton.isHidden = true
            //todo: bearbeiten possibility
        } else {
            self.navigationItem.title = "Check Availibility"
            reservationButton.isEnabled = false
        }

        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
       /* if let psd = preselectedStartDate, let ped = preselectedEndDate {
            print("preselected dates")
            calendarView.scrollToHeaderForDate(psd)
            calendarView.selectDates(from: psd, to: ped)
        } */
        
        calendarView.visibleDates { visibleDates in
            self.setupMonthYear(from: visibleDates)
        }
        
        calendarView.allowsMultipleSelection = true
       // calendarView.isRangeSelectionUsed = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func handleSelectionVisually(view: JTAppleCell?, cellState: CellState){
        guard let cell = view as? AvailibilityCalendarCell else {return}
        
    if cellState.dateBelongsTo == .thisMonth {
        switch cellState.selectedPosition() {
        case .full, .left, .right, .middle:
            cell.dateLabel.textColor = selectedColor
            cell.availibility.isBlocked = false

        default:
            cell.dateLabel.textColor = releasedColor
            cell.availibility.isBlocked = true
        }
    }
        
     /*   if cellState.dateBelongsTo == .thisMonth {
            if cellState.isSelected {
                cell.dateLabel.textColor = selectedColor
                cell.availibility.isBlocked = false
            } else {
                cell.dateLabel.textColor = releasedColor
                cell.availibility.isBlocked = true
            }
        }*/
    }
    
    func handleMonthColors(view: JTAppleCell?, cellState: CellState){
        guard let cell = view as? AvailibilityCalendarCell else {return}
        
        if cellState.isSelected {
            cell.dateLabel.textColor = selectedColor
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                cell.dateLabel.textColor = releasedColor
            } else {
                cell.dateLabel.textColor = notInMonthColor
            }
        }
    }
    
    func setupMonthYear(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "MMMM yy"
        monthAndYear.text = formatter.string(from: date)
    }

    func checkAvailibility() -> Void {
        resultView.text = "Checking for availibility..."
        
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
                    self.resultView.text = "Not availible - try another date! :)"
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
                                self.resultView.text = "Not availible - try another date! :)"
                                return
                            }
                        }
                    })
                })
            }
        })
        
        self.resultView.text = "Yey, the car is availible!"
        calculatePrice(rentingIntervall: intervall2Check!)
    }
    
    func calculatePrice(rentingIntervall: DateInterval) -> Void {
        let intervalLength : Float = Float(Calendar.current.dateComponents([.day], from: rentingIntervall.start, to: rentingIntervall.end).day!)
        
        let priceperDay: Float = Float((offer?.basePrice)!)
    
        priceView.text = "Price per day: \(priceperDay)"
        
        //calculate discount depending on rating
        //todo: frühbucherrabatt?
        storageAPI.getUserByUID(UID: storageAPI.userID()) { (user) in
            let rating: Float = user.rating
            var discount: Float = 0
            
            if (rating < 4) {
                self.discountView.text = "No discount yet - go and get at least 4 stars!"
            } else if (rating >= 4 && rating < 4.9) { //get 5% discount
                discount = priceperDay*0.05
                self.discountView.text = "5% discount: -\(discount)"
            } else if (rating >= 4.9) { //get 10% discount
                discount = priceperDay*0.1
                self.discountView.text = "10% discount: -\(discount)"
            } else {
                self.discountView.text = "No discount yet - go and get at least 4 stars!"
            }
            
            self.totalPrice = ((priceperDay - discount) * intervalLength)
            self.totalPriceView.text = "Total price: \(self.totalPrice)"
            self.reservationButton.isEnabled = true
        }
    }
    
    @IBAction func reserve(_ sender: Any) {
        reservationButton.isEnabled = false
        resultView.text = "Reservation in progress..."
        priceView.text = ""
        discountView.text = ""
        totalPriceView.text = ""
        storageAPI.generateRentingKey(completion: {(rentingID) in
            let renting = Renting(id: rentingID, inseratID: self.offer!.id!, userID: self.storageAPI.userID(), startDate: self.firstDate!, endDate: self.lastDate!, confirmationStatus: false, rentingPrice: self.totalPrice)
            self.storageAPI.saveRenting(renting: renting, completion: { (statusMessage) in
                if (statusMessage == StorageAPI.STORAGE_API_SUCCESS) {
                    //TODO: go back to startseite
                    //chat message to lessor from default user
                    //todo: Methoden in MessageHandler erstellen?
                    MessageHandler._shared.sendMessage(senderID: MessageHandler.defaultUserButtlerJamesID, senderName: MessageHandler.defaultUserButtlerJamesName, text: MessageHandler.DEFAULT_MESSAGE_RENTING_REQUEST + " " + self.offer!.type + " for " + "\(self.totalPrice)" + " €", receiverID: self.offer!.id!);
                } else {
                    self.reservationButton.isEnabled = true
                    self.resultView.text = ""
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
        let myCustomCell = cell as! AvailibilityCalendarCell
        let availibility = Availibility(date: date)
        myCustomCell.availibility = availibility
        myCustomCell.dateLabel.text = cellState.text
        handleMonthColors(view: myCustomCell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "availibilityCalendarCell", for: indexPath) as! AvailibilityCalendarCell
        self.calendar(calendar, willDisplay: myCustomCell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return myCustomCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        dates2Check.append(date)
        guard let selectedDate = cell as? AvailibilityCalendarCell else {return}
        handleSelectionVisually(view: selectedDate, cellState: cellState)
        
        if recursiveSelectionCall == false {
            if let currentFirstDate = firstDate {
                if lastDate != nil {
                    calendarView.deselectDates(from: currentFirstDate, to: currentFirstDate, triggerSelectionDelegate: true)
                    resultView.text = ""
                    priceView.text = ""
                    discountView.text = ""
                    totalPriceView.text = ""
                    reservationButton.isEnabled = false
                    firstDate = date
                    lastDate = nil
                } else {
                    if (date < currentFirstDate){
                        recursiveDeselectionCall = true
                        calendarView.deselectDates(from: firstDate!, to: firstDate!, triggerSelectionDelegate: true)
                        recursiveDeselectionCall = false
                        resultView.text = ""
                        priceView.text = ""
                        discountView.text = ""
                        totalPriceView.text = ""
                        reservationButton.isEnabled = false
                        firstDate = date
                        lastDate = nil
                    } else {
                        lastDate = date
                        if (firstDate != lastDate) {
                            recursiveSelectionCall = true
                            calendarView.selectDates(from: currentFirstDate, to: date,  triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: true)
                            checkAvailibility()
                            print("a valid intervall is selected selected, check availibility")
                            recursiveSelectionCall = false
                        }
                    }
                }
            } else {
                firstDate = date
                lastDate = firstDate
                checkAvailibility()
                print("only on cell selected, check availibility")
            }
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print(cellState.selectedPosition)
        if !(cellState.selectedPosition() == .middle) {
            if dates2Check.count > 0 {
                if let index = dates2Check.index(of: date) {
                    dates2Check.remove(at: index)
                }
            }
            
            guard let releasedDate = cell as? AvailibilityCalendarCell else {return}
            handleSelectionVisually(view: releasedDate, cellState: cellState)
        }
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
