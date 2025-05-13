//
//  DateHelper.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation

struct DateHelper {

    static let iCalDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
    
    static func formatDateRange(from startDate: Date, to endDate: Date) -> String {
        let start = dateFormatter.string(from: startDate)
        let end = dateFormatter.string(from: endDate)
        return "\(start) - \(end)"
    }
    
    static func formatTimeRange(from startTime: Date, to endTime: Date) -> String {
        let start = timeFormatter.string(from: startTime)
        let end = timeFormatter.string(from: endTime)
        return "\(start) - \(end)"
    }
    
    static func datesForTrip(startDate: Date, endDate: Date) -> [Date] {
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    static func startOfDay(for date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    static func endOfDay(for date: Date) -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay(for: date))!
    }

    static func formatForICal(date: Date) -> String {
        return iCalDateFormatter.string(from: date)
    }
    
}

