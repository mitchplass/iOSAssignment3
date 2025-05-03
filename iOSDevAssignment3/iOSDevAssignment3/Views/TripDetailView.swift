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
            // TimetableView(trip: trip)
            EmptyView()
                .tabItem {
                    Label("Timetable", systemImage: "calendar")
                }
                .tag(0)
            
            // ItemsView(trip: trip)
            EmptyView()
                .tabItem {
                    Label("Items", systemImage: "checklist")
                }
                .tag(1)
            
            // ExpensesView(trip: trip)
            EmptyView()
                .tabItem {
                    Label("Expenses", systemImage: "dollarsign.circle")
                }
                .tag(2)
            
            // TripInfoView(trip: trip)
            EmptyView()
                .tabItem {
                    Label("Info", systemImage: "info.circle")
                }
                .tag(3)
        }
        .navigationTitle(trip.name)
    }
}
