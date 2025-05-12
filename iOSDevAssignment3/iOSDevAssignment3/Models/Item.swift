//
//  Item.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation

enum ItemStatus: String, Codable, CaseIterable, Identifiable {
    case needed, packed, purchased
    var id: String { self.rawValue }
    var displayName: String { self.rawValue.capitalized }
    var systemImage: String {
        switch self {
        case .needed: return "circle"
        case .packed: return "checkmark.circle.fill"
        case .purchased: return "cart.circle.fill"
        }
    }
}

struct Item: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var quantity: Int = 1
    var assignedTo: Person.ID?
    var status: ItemStatus = .needed
    var category: String? = "General"
    var isShared: Bool = true

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Item, rhs: Item) -> Bool { lhs.id == rhs.id }
}
