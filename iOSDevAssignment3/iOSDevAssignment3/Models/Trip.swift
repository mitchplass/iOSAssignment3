//
//  Trip.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation

struct Trip: Identifiable, Codable {
    var id = UUID()
    var name: String
    var destination: Destination
    var startDate: Date
    var endDate: Date
    var participants: [Person]
    var activities: [Activity]
    var items: [Item]
    var expenses: [Expense]
    
    var numberOfDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day! + 1
    }
}
