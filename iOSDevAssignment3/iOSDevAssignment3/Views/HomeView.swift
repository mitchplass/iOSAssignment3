//
//  HomeView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 3/7/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    @State private var showingNewTripView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                if tripViewModel.currentTrip != nil {
                    VStack {
                        HStack {
                            Button("Back") {
                                tripViewModel.currentTrip = nil
                            }
                            .padding(.leading)
                            
                            Spacer()
                        }
                        
                        TripDetailView(trip: tripViewModel.currentTrip!)
                    }
                } else {
                    VStack {
                        List {
                            if tripViewModel.trips.isEmpty {
                                Text("No trips yet")
                                    .foregroundColor(.gray)
                            } else {
                                ForEach(tripViewModel.trips.sorted(by: { $0.startDate < $1.startDate })) { trip in
                                    Button(action: {
                                        tripViewModel.currentTrip = trip
                                    }) {
                                        VStack(alignment: .leading) {
                                            Text(trip.name)
                                                .font(.headline)
                                            
                                            Text(trip.destination)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            Text(formatDateRange(from: trip.startDate, to: trip.endDate))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .onDelete(perform: deleteTrips)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                    .navigationTitle("Trips")
                    .navigationBarItems(trailing:
                        Button(action: {
                            showingNewTripView = true
                        }) {
                            Image(systemName: "plus")
                        }
                    )
                    .sheet(isPresented: $showingNewTripView) {
                        NewTripView(showingNewTripView: $showingNewTripView)
                    }
                }
            }
        }
    }
    
    private func deleteTrips(at offsets: IndexSet) {
        for index in offsets {
            let trip = tripViewModel.trips.sorted(by: { $0.startDate < $1.startDate })[index]
            tripViewModel.deleteTrip(id: trip.id)
        }
    }
    
    private func formatDateRange(from startDate: Date, to endDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(TripViewModel())
    }
}