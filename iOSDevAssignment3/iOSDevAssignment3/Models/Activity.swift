//
//  Activity.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation

struct Activity: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var date: Date
    var startTime: Date
    var endTime: Date
    var participants: [Person]
    var location: String
    
    var isAllDay: Bool {
        Calendar.current.isDate(startTime, equalTo: endTime, toGranularity: .hour) &&
        Calendar.current.component(.hour, from: startTime) == 0 &&
        Calendar.current.component(.hour, from: endTime) == 23
    }
}
