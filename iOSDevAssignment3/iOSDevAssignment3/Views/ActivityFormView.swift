//
//  ActivityFormView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 3/7/25.
//

import Foundation
import SwiftUI

struct ActivityFormView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    @Binding var isPresented: Bool
    let trip: Trip
    var existingActivity: Activity?
    var isEditing: Bool

    @State private var title = ""
    @State private var descriptionText = ""
    @State private var date: Date
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var location = ""
    @State private var selectedParticipantIDs: [Person.ID] = []
    @State private var showingParticipantSelection = false

    init(isPresented: Binding<Bool>, trip: Trip, activityDate: Date? = nil, existingActivity: Activity? = nil) {
        self._isPresented = isPresented
        self.trip = trip
        self.existingActivity = existingActivity
        self.isEditing = existingActivity != nil
        
        if let activity = existingActivity {
            self._title = State(initialValue: activity.title)
            self._descriptionText = State(initialValue: activity.description)
            self._date = State(initialValue: activity.date)
            self._startTime = State(initialValue: activity.startTime)
            self._endTime = State(initialValue: activity.endTime)
            self._location = State(initialValue: activity.location)
            self._selectedParticipantIDs = State(initialValue: activity.participants)
        } else {
            let defaultDate = activityDate ?? trip.startDate
            self._date = State(initialValue: defaultDate)
            self._title = State(initialValue: "")
            self._descriptionText = State(initialValue: "")
            self._location = State(initialValue: "")
            self._selectedParticipantIDs = State(initialValue: [])

            var startComponents = Calendar.current.dateComponents([.year, .month, .day], from: defaultDate)
            startComponents.hour = 9; startComponents.minute = 0
            self._startTime = State(initialValue: Calendar.current.date(from: startComponents) ?? defaultDate)

            var endComponents = startComponents
            endComponents.hour = 10
            self._endTime = State(initialValue: Calendar.current.date(from: endComponents) ?? defaultDate.addingTimeInterval(3600))
        }
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
                        .onChange(of: startTime) { _ in
                            adjustEndTimeIfInvalid()
                        }
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .onChange(of: endTime) { _ in
                            adjustEndTimeIfInvalid()
                        }
                }

                Section(header: Text("Participants (\(selectedParticipantIDs.count) selected)")) {
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
            .navigationTitle(isEditing ? "Edit Activity" : "Add Activity")
            .toolbar { // Replaced navigationBarItems
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditing ? "Save" : "Add") {
                        saveActivity()
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

    private func saveActivity() {
        let combinedStartDate = combine(date: date, with: startTime)
        let combinedEndDate = combine(date: date, with: endTime)

        if isEditing, let existingActivity = existingActivity {
            let updatedActivity = Activity(
                id: existingActivity.id,
                title: title,
                description: descriptionText,
                date: date,
                startTime: combinedStartDate,
                endTime: combinedEndDate,
                participants: selectedParticipantIDs,
                location: location,
                notes: existingActivity.notes
            )
            tripViewModel.updateActivity(in: trip.id, activity: updatedActivity)
        } else {
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
        }
        isPresented = false
    }

    private func isEndTimeInvalid() -> Bool {
        combine(date: date, with: endTime) <= combine(date: date, with: startTime)
    }

    private func adjustEndTimeIfInvalid() {
        if isEndTimeInvalid() {
            let newEndTime = Calendar.current.date(byAdding: .hour, value: 1, to: startTime) ?? startTime.addingTimeInterval(3600)
            endTime = newEndTime
        }
    }

    private func combine(date: Date, with time: Date) -> Date {
        let hour = Calendar.current.component(.hour, from: time)
        let minute = Calendar.current.component(.minute, from: time)
        return Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }
}