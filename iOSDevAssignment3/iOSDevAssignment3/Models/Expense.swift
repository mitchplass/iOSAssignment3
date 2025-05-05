//
//  Expense.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation

struct Expense: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var date: Date
    var paidBy: UUID
    var splitAmong: [Person]
    var category: ExpenseCategory
    
    var amountPerPerson: Double {
        if splitAmong.isEmpty {
            return 0
        }
        return amount / Double(splitAmong.count)
    }
}

enum ExpenseCategory: String, Codable, CaseIterable {
    case accommodation
    case transportation
    case food
    case activities
    case other
    
    var icon: String {
        switch self {
        case .accommodation: return "house"
        case .transportation: return "car"
        case .food: return "fork.knife"
        case .activities: return "ticket"
        case .other: return "square.grid.2x2"
        }
    }
}
