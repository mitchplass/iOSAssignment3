//
//  Person.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation

struct Person: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var email: String
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        lhs.id == rhs.id
    }
}
