//
//  ContentView.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    @State private var showingNewTripView = false
    
    var body: some View {
        ZStack {
            if tripViewModel.currentTrip != nil {
                VStack {
                    HStack {
                        Button("Back to Trips") {
                            tripViewModel.currentTrip = nil
                        }
                        .padding(.leading)
                        
                        Spacer()
                    }
                    .padding(.top)
                    
                    TripDetailView(trip: tripViewModel.currentTrip!)
                        .padding(.top, 8)
                }
            } else {
                VStack {
                    HStack {
                        Text("TripSync")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            showingNewTripView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                        }
                        .padding(.trailing)
                    }
                    .padding(.top)
                    
                    TripListView()
                        .padding(.top, 8)
                }
                .sheet(isPresented: $showingNewTripView) {
                    NewTripView(showingNewTripView: $showingNewTripView)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(TripViewModel())
    }
}
