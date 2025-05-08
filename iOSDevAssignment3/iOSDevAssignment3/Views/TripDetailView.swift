//
//  TripDetailView.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation
import SwiftUI

struct TripDetailView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    let trip: Trip
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TimetableView(trip: trip)
                .tabItem {
                    Label("Timetable", systemImage: "calendar")
                }
                .tag(0)
            
            DestinationView(destination: trip.destination)
                .tabItem {
                    Label("Destination", systemImage: "map")
                }
                .tag(1)
            
            ItemsView(trip: trip)
                .tabItem {
                    Label("Items", systemImage: "checklist")
                }
                .tag(2)
            
            ExpensesView(trip: trip)
                .tabItem {
                    Label("Expenses", systemImage: "dollarsign.circle")
                }
                .tag(3)
            
            TripInfoView(trip: trip)
                .tabItem {
                    Label("Info", systemImage: "info.circle")
                }
                .tag(4)
        }
        .navigationTitle(trip.name)
    }
}
