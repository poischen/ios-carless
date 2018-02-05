//
//  CalendaLogic.swift
//  ios
//
//  Created by Konrad Fischer on 01.02.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import Foundation

class CalendarLogic {
    static func didSelectDate(usingCalendar: UsingCalendar, selectedDate: Date){
        if usingCalendar.recursiveSelectionCall == false { // ... but only examine whether a recursive call is necessary when this isn't already a recursive cell
            if let currentFirstDate = usingCalendar.firstDate {
                // first date set
                if usingCalendar.lastDate != nil {
                    // date range already set -> remove and set new first date
                    // deselecting one date is enough as the shouldDeselect function ensures that when one date from the current date interval is deselected all others are also
                    usingCalendar.calendarView.deselectDates(from: currentFirstDate, to: currentFirstDate, triggerSelectionDelegate: true)
                    usingCalendar.firstDate = selectedDate
                    usingCalendar.lastDate = nil
                } else {
                    // first date set, last date not set
                    if (selectedDate < currentFirstDate){
                        /* new date is before first date -> remove first date and set current date as new first date
                         first deselect current date interval
                         deselecting one date is enough as the shouldDeselect function ensures that when one date from the current date interval is deselected all others are also */
                        usingCalendar.recursiveDeselectionCall = true
                        usingCalendar.calendarView.deselectDates(from: currentFirstDate, to: currentFirstDate, triggerSelectionDelegate: true)
                        usingCalendar.recursiveDeselectionCall = false
                        usingCalendar.firstDate = selectedDate // deselection resets first date -> set after deselection
                        usingCalendar.lastDate = nil // for safety :)
                    } else {
                        // new date is on or after first date -> set last date
                        usingCalendar.lastDate = selectedDate
                        if (usingCalendar.firstDate != usingCalendar.lastDate) {
                            // first date and last date are not on the same day -> select cells in between
                            usingCalendar.recursiveSelectionCall = true // prevent endless recursion
                            usingCalendar.calendarView.selectDates(from: currentFirstDate, to: selectedDate,  triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: true)
                            usingCalendar.recursiveSelectionCall = false
                        }
                    }
                }
            } else {
                // first date not set yet -> set first date
                usingCalendar.firstDate = selectedDate
            }
        }
    }
    
    static func shouldDeselectDate(usingCalendar: UsingCalendar) -> Bool{
        // this function ensures that when one date from the current date interval is deselected all others are too
        // -> deselecting one date from the current date interval is sufficient
        if usingCalendar.recursiveDeselectionCall == true {
            // this is a reursive call -> only deselect cell and don't start a new recursive call
            return true
        } else {
            if let currentFistDate = usingCalendar.firstDate, let currentLastDate = usingCalendar.lastDate {
                // deselect current date interval
                usingCalendar.recursiveDeselectionCall = true // prevent endless recursion
                usingCalendar.calendarView.deselectDates(from: currentFistDate, to: currentLastDate, triggerSelectionDelegate: true)
                usingCalendar.recursiveDeselectionCall = false
                // unset first date and last date
                usingCalendar.firstDate = nil
                usingCalendar.lastDate = nil
            }
            return false
        }
    }
}
