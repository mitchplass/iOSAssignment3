//
//  Item.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation

enum ItemStatus: String, Codable {
    case needed, packed, purchased
}

struct Item: Identifiable, Codable {
    var id = UUID()
    var name: String
    var quantity: Int
    var assignedTo: UUID?
    var status: ItemStatus
}
