//
//  TimetableView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 3/7/25.
//

import Foundation
import SwiftUI

struct TimetableView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    let trip: Trip
    
    @Binding var currentSelectedDateFromTimetable: Date?
    
    @State private var selectedDayIndex = 0
    @State private var showingEditActivitySheet = false
    @State private var activityToEdit: Activity? = nil
    @State private var showingDeleteConfirmation = false
    @State private var activityToDelete: Activity? = nil
    
    private func editActivity(_ activity: Activity) {
        activityToEdit = activity
        showingEditActivitySheet = true
    }
    
    var days: [Date] {
        let calendar = Calendar.current; let startDate = calendar.startOfDay(for: trip.startDate)
        return (0..<trip.numberOfDays).compactMap { day in calendar.date(byAdding: .day, value: day, to: startDate) }
    }
        
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(days.indices, id: \.self) { index in
                        DayButton(day: days[index], isSelected: index == selectedDayIndex) {
                            selectedDayIndex = index
                            if !days.isEmpty && days.indices.contains(index) {
                                currentSelectedDateFromTimetable = days[index]
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
            
            if !days.isEmpty && days.indices.contains(selectedDayIndex) {
                let currentSelectedDate = days[selectedDayIndex]
                let activitiesForDay = trip.activities.filter { Calendar.current.isDate($0.date, inSameDayAs: currentSelectedDate) }.sorted { $0.startTime < $1.startTime }
                
                if activitiesForDay.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Text("No activities planned for this day").font(.headline).foregroundColor(.gray)
                        Text("Use the '+' button in the toolbar to add an activity.").font(.caption).foregroundColor(.gray)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(activitiesForDay) { activity in
                                ActivityCell(activity: activity, allTripParticipants: trip.participants)
                                    .onTapGesture {
                                        editActivity(activity)
                                    }
                                    .contextMenu {
                                        Button(action: { editActivity(activity) }) { 
                                            Label("Edit", systemImage: "pencil") 
                                        }
                                        Button(role: .destructive, action: {
                                            activityToDelete = activity
                                            showingDeleteConfirmation = true
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                }
            } else {
                VStack {
                    Spacer()
                    Text("No dates available for this trip.")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .onAppear {
            if currentSelectedDateFromTimetable == nil, !days.isEmpty, days.indices.contains(selectedDayIndex) {
                currentSelectedDateFromTimetable = days[selectedDayIndex]
            }
        }
        .sheet(isPresented: $showingEditActivitySheet, onDismiss: {
            activityToEdit = nil
        }) {
            if let activity = activityToEdit {
                ActivityFormView(
                    isPresented: $showingEditActivitySheet,
                    trip: trip,
                    existingActivity: activity
                )
            }
        }
        .alert("Delete Activity", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                activityToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let activity = activityToDelete {
                    deleteActivity(activity)
                    activityToDelete = nil
                }
            }
        } message: {
            Text("Are you sure you want to delete this activity?")
        }
    }

    private func deleteActivity(_ activity: Activity) {
        tripViewModel.deleteActivity(from: trip.id, activityId: activity.id)
    }
}

struct DayButton: View {
    let day: Date
    let isSelected: Bool
    let action: () -> Void
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter
    }()
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(dateFormatter.string(from: day))
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("\(calendar.component(.day, from: day))")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .foregroundColor(isSelected ? .white : .primary)
            .frame(width: 50, height: 60)
            .background(isSelected ? Color.blue : Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

struct ActivityCell: View {
    let activity: Activity
    let allTripParticipants: [Person]

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()

    private var participantNames: String {
        let names = activity.participants.compactMap { id in
            allTripParticipants.first { $0.id == id }?.name
        }
        return names.isEmpty ? "No participants assigned" : names.joined(separator: ", ")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .trailing) {
                Text(timeFormatter.string(from: activity.startTime))
                    .font(.caption)
                    .fontWeight(.medium)
                
                if !activity.isAllDay {
                    Text(timeFormatter.string(from: activity.endTime))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 65, alignment: .trailing)
            
            VStack(alignment: .center, spacing: 0) {
                Circle().fill(Color.blue).frame(width: 10, height: 10)
                Rectangle().fill(Color.blue).frame(width: 2).frame(maxHeight: .infinity)
            }
            .frame(width: 10)


            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.headline)
                
                if !activity.description.isEmpty {
                    Text(activity.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !activity.location.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        Text(activity.location)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if !activity.participants.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .foregroundColor(.blue)
                        Text(participantNames)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                } else {
                     HStack(spacing: 4) {
                        Image(systemName: "person.2")
                            .foregroundColor(.gray)
                        Text("No participants assigned")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.leading, 4)
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}
