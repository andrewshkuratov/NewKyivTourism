//
//  DateExtension.swift
//  NewKyivTourism
//
//  Created by Andrew on 02.06.2021.
//

import Foundation

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(self.timeIntervalSinceNow) * (-1)
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let quotient: Int
        var unit: String
        
        if secondsAgo < minute {
            quotient = secondsAgo
            unit = NSLocalizedString("second", comment: "")
        } else if secondsAgo < hour {
            quotient = Int(secondsAgo / minute)
            unit = NSLocalizedString("min", comment: "")
        } else if secondsAgo < day {
            quotient = Int(secondsAgo / hour)
            unit = NSLocalizedString("hour", comment: "")
        } else if secondsAgo < week {
            quotient = Int(secondsAgo / day)
            unit = NSLocalizedString("day", comment: "")
        } else if secondsAgo < month {
            quotient = Int(secondsAgo / week)
            unit = NSLocalizedString("week", comment: "")
        } else {
            quotient = Int(secondsAgo / month)
            unit = NSLocalizedString("month", comment: "")
        }
        
        return "\(quotient) \(unit) \(quotient == 1 ? "" : NSLocalizedString("s", comment: "")) " + NSLocalizedString("ago", comment: "")
    }
}
