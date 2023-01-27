//
//  Date+Extension.swift
//  

import Foundation

enum DateFormat: String {
    case timeWith12Hour = "hh:mm a"
    case dateTime = "MM-dd-yyyy hh:mm a"
    case appDate = "MM-dd-yyyy"
    case smallYear = "MM-dd-yy"
}

struct DateModel {
    var years: Int?
    var months: Int?
    var days: Int?
    var hours: Int?
    var minutes: Int?
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970).rounded())
    }
    
    var millisecondsSince1970MultiplyBy10:Int {
        return Int((self.timeIntervalSince1970 * 10.0).rounded())
    }
    
    var millisecondsSince1970MultiplyBy1000:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds))
    }
    
    init(millisecondsDividedBy10:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(millisecondsDividedBy10) / 10)
    }
    
    init(millisecondsDividedBy1000:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(millisecondsDividedBy1000) / 1000)
    }
    
    var isDateInToday: Bool {
        let todayDateString = Date().getString(format: .appDate)
        let todayDate = Date.dateFromString(todayDateString, format: .appDate) ?? Date()
        let resultDateString = self.getString(format: .appDate)
        let resultDate = Date.dateFromString(resultDateString, format: .appDate) ?? Date()
        return Calendar.current.isDate(resultDate, inSameDayAs: todayDate)
    }
        
    func getString(format: DateFormat = .timeWith12Hour, timeZone: TimeZone = .current) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = DateFormat.dateTime.rawValue
        
        let dateString = formatter.string(from: self)
        let date = formatter.date(from: dateString)
        formatter.dateFormat = format.rawValue
        let timeString = formatter.string(from: date!)
        return timeString
    }
    
    func getDate(format: DateFormat = .appDate) -> Date? {
        let dateString = self.getString(format: format)
        let date = Date.dateFromString(dateString, format: format)
        return date
    }
    
    static func dateFromString(_ dateString: String, format: DateFormat, timeZone: TimeZone = .current) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = timeZone
        let date = dateFormatter.date(from: dateString)
        return date
    }
    
    func timeAgoSinceDate() -> String {
        // From Time
        let fromDate = self
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        return "a moment ago"
    }
    
    func timeTillDate(_ date: Date) -> DateModel {
        // From Time
        let fromDate = self
        var dateModel = DateModel()
        
        
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: date).year, interval > 0  {
            dateModel.years = interval
        }
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: date).month, interval > 0  {
            dateModel.months = interval
        }
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: date).day, interval > 0  {
            dateModel.days = interval
        }
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: date).hour, interval > 0 {
            dateModel.hours = interval
        }
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: date).minute, interval > 0 {
            dateModel.minutes = interval
        }
        return dateModel
    }
    
    func getDaysFromDate(_ date: Date) -> Int {
        let calendar = Calendar.current

        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: date1, to: date2)
        return components.day ?? 0
    }
}
