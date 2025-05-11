//
//  AddActivityView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 3/7/25.
//

import Foundation
import SwiftUI

struct AddActivityView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    @Binding var isPresented: Bool
    let trip: Trip
    
    @State private var title = ""
    @State private var descriptionText = ""
    @State private var date: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var location = ""
    @State private var selectedParticipantIDs: [Person.ID] = []
    @State private var showingParticipantSelection = false
    
    init(isPresented: Binding<Bool>, trip: Trip, activityDate: Date? = nil) {
        self._isPresented = isPresented
        self.trip = trip

        let defaultDate = activityDate ?? trip.startDate
        self._date = State(initialValue: defaultDate)

        var startComponents = Calendar.current.dateComponents([.year, .month, .day], from: defaultDate)
        startComponents.hour = 9; startComponents.minute = 0
        self._startTime = State(initialValue: Calendar.current.date(from: startComponents) ?? defaultDate)

        var endComponents = startComponents
        endComponents.hour = 10
        self._endTime = State(initialValue: Calendar.current.date(from: endComponents) ?? defaultDate.addingTimeInterval(3600))
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $descriptionText)
                    TextField("Location", text: $location)
                }
                
                Section(header: Text("Date & Time")) {
                    DatePicker("Date", selection: $date, in: trip.startDate...trip.endDate, displayedComponents: .date)
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Participants (\(selectedParticipantIDs.count) selected)")) {
                    // Display selected participant names
                    ForEach(selectedParticipantIDs, id: \.self) { id in
                        if let person = trip.participants.first(where: { $0.id == id }) {
                            Text(person.name)
                        }
                    }
                    
                    Button(action: {
                        showingParticipantSelection = true
                    }) {
                        Label("Select Participants", systemImage: "person.badge.plus")
                    }
                }
            }
            .navigationTitle("Add Activity")
            .toolbar { // Replaced navigationBarItems
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addActivity()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .sheet(isPresented: $showingParticipantSelection) {
                MultiSelectParticipantIDView(
                    allParticipants: trip.participants,
                    selectedParticipantIDs: $selectedParticipantIDs
                )
            }
        }
    }
    
    private func addActivity() {
        let startHour = Calendar.current.component(.hour, from: startTime)
        let startMinute = Calendar.current.component(.minute, from: startTime)
        let endHour = Calendar.current.component(.hour, from: endTime)
        let endMinute = Calendar.current.component(.minute, from: endTime)
        
        let combinedStartDate = Calendar.current.date(
            bySettingHour: startHour, minute: startMinute, second: 0, of: date
        ) ?? date
        
        let combinedEndDate = Calendar.current.date(
            bySettingHour: endHour, minute: endMinute, second: 0, of: date
        ) ?? date.addingTimeInterval(3600)
        
        let newActivity = Activity(
            title: title,
            description: descriptionText,
            date: date,
            startTime: combinedStartDate,
            endTime: combinedEndDate,
            participants: selectedParticipantIDs,
            location: location
        )
        
        tripViewModel.addActivity(to: trip.id, activity: newActivity)
        isPresented = false
    }
}
