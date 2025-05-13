//
//  Activity.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation

struct Activity: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var description: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var participants: [Person.ID]
    var location: String
    var emoji: String = "🏙️"
    var notes: String? = nil

    var isAllDay: Bool {
        let calendar = Calendar.current
        guard calendar.isDate(startTime, inSameDayAs: endTime) else {
            return false
        }
        let startOfDayForStartTime = calendar.startOfDay(for: startTime)
        var endOfDayComponents = DateComponents()
        endOfDayComponents.day = 1
        endOfDayComponents.second = -1
        let endOfDayForStartTime = calendar.date(byAdding: endOfDayComponents, to: startOfDayForStartTime)!
        let isStartTimeAtBeginning = calendar.isDate(startTime, equalTo: startOfDayForStartTime, toGranularity: .minute)
        let isEndTimeAtEnd = calendar.isDate(endTime, equalTo: endOfDayForStartTime, toGranularity: .minute)
        return isStartTimeAtBeginning && isEndTimeAtEnd
    }

    static func == (lhs: Activity, rhs: Activity) -> Bool {
        lhs.id == rhs.id
    }
}
