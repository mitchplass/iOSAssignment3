//
//  Trip.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation

struct Trip: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var participants: [Person]
    var activities: [Activity]
    var items: [Item]
    var expenses: [Expense]
    
    var numberOfDays: Int {
        guard startDate <= endDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: startDate, to: endDate).day! + 1
    }

    static func == (lhs: Trip, rhs: Trip) -> Bool {
        lhs.id == rhs.id
    }
}
