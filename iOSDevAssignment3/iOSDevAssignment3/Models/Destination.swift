//
//  Destination.swift
//  iOSDevAssignment3
//
//  Created by Mitchell Plass on 7/5/2025.
//

import Foundation

struct Destination: Identifiable, Codable {
    var id = UUID()
    var name: String
    var lat: String
    var long: String
}
