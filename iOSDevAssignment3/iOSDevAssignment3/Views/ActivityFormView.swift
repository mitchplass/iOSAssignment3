//
//  ActivityFormView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 7/5/25.
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
    @State private var emoji = "🏙️"
    @State private var showingParticipantSelection = false
    @State private var showingDeleteConfirmation = false
    @State private var showingEmojiPicker = false

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
            self._emoji = State(initialValue: activity.emoji)
        } else {
            let defaultDate = activityDate ?? trip.startDate
            self._date = State(initialValue: defaultDate)
            self._title = State(initialValue: "")
            self._descriptionText = State(initialValue: "")
            self._location = State(initialValue: "")

            let currentUserId = trip.participants.first?.id
            self._selectedParticipantIDs = State(initialValue: currentUserId != nil ? [currentUserId!] : [])

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
                    HStack {
                        Button(action: {
                            showingEmojiPicker = true
                        }) {
                            Text(emoji)
                                .font(.largeTitle)
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .padding(.trailing, 8)
                        TextField("Title", text: $title)
                    }
                    TextField("Description", text: $descriptionText)
                    TextField("Location", text: $location)
                }

                Section(header: Text("Date & Time")) {
                    DatePicker("Date", selection: $date, in: trip.startDate...trip.endDate, displayedComponents: .date)
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .onChange(of: startTime) {
                            adjustEndTimeIfInvalid()
                        }
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .onChange(of: endTime) {
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

                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack {
                                Spacer()
                                Label("Delete Activity", systemImage: "trash")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
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
            .sheet(isPresented: $showingEmojiPicker) {
                EmojiPickerView(selectedEmoji: $emoji)
            }
            .alert("Delete Activity", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteActivity()
                }
            } message: {
                Text("Are you sure you want to delete this activity?")
            }
        }
    }
    
    private func deleteActivity() {
        if let activity = existingActivity {
            tripViewModel.deleteActivity(from: trip.id, activityId: activity.id)
            isPresented = false
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
                emoji: emoji,
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
                location: location,
                emoji: emoji
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