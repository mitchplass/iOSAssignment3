//
//  TripListView.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation
import SwiftUI

struct TripListView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    
    var body: some View {
        List {
            if tripViewModel.trips.isEmpty {
                Text("No trips yet. Create your first trip by tapping the + button.")
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowBackground(Color.clear)
                    .padding()
            } else {
                ForEach(tripViewModel.trips.sorted(by: { $0.startDate < $1.startDate })) { trip in
                    TripRowView(trip: trip)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            tripViewModel.currentTrip = trip
                        }
                }
                .onDelete(perform: deleteTrips)
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func deleteTrips(at offsets: IndexSet) {
        for index in offsets {
            let trip = tripViewModel.trips.sorted(by: { $0.startDate < $1.startDate })[index]
            tripViewModel.deleteTrip(id: trip.id)
        }
    }
}

struct TripRowView: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(trip.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(trip.destination.name)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(DateHelper.formatDateRange(from: trip.startDate, to: trip.endDate))
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack {
                Image(systemName: "person.2")
                Text("\(trip.participants.count) participants")
                Spacer()
                Image(systemName: "calendar")
                Text("\(trip.numberOfDays) days")
            }
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }
}
