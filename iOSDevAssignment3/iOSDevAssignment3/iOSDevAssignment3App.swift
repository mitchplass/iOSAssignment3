//
//  iOSDevAssignment3App.swift
//  iOSDevAssignment3
//
//  Created by Mitchell Plass on 2/5/2025.
//

import SwiftUI

@main
struct iOSDevAssignment3App: App {
    @StateObject private var tripViewModel = TripViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(tripViewModel)
        }
    }
}
