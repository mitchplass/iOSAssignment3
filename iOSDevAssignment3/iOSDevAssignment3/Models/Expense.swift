//
//  Expense.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation

struct Expense: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var amount: Double
    var date: Date
    var paidBy: Person.ID
    var splitAmong: [Person.ID]
    var category: ExpenseCategory
    var notes: String? = nil
    var receiptImageData: Data? = nil
    var customSplitAmounts: [Person.ID: Double]? = nil

    func amountOwedBy(_ personId: Person.ID, totalParticipantsInSplit: Int, tripParticipants: [Person]) -> Double {
        if let customAmounts = customSplitAmounts, let customAmount = customAmounts[personId] {
            return customAmount
        }
        guard splitAmong.contains(personId), totalParticipantsInSplit > 0 else { return 0 }
        return amount / Double(totalParticipantsInSplit)
    }
    
    var numberOfSharers: Int {
        splitAmong.count
    }

    static func == (lhs: Expense, rhs: Expense) -> Bool {
        lhs.id == rhs.id
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
