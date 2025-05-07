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
    @State private var showingAddActivity = false
    @State private var selectedDay = 0
    
    var days: [Date] {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: trip.startDate)
        
        return (0..<trip.numberOfDays).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: startDate)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Day selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(days.indices, id: \.self) { index in
                        DayButton(
                            day: days[index],
                            isSelected: index == selectedDay,
                            action: {
                                selectedDay = index
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color(UIColor.secondarySystemBackground))
            
            // Activities for the selected day
            if selectedDay >= 0 && selectedDay < days.count {
                let selectedDate = days[selectedDay]
                let activitiesForDay = trip.activities.filter {
                    Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                }.sorted { $0.startTime < $1.startTime }
                
                if activitiesForDay.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Text("No activities planned for this day")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showingAddActivity = true
                        }) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Activity")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemBackground))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(activitiesForDay) { activity in
                                ActivityCell(activity: activity)
                                    .contextMenu {
                                        Button(role: .destructive, action: {
                                            deleteActivity(activity)
                                        }) {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                            
                            Button(action: {
                                showingAddActivity = true
                            }) {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("Add Another Activity")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(UIColor.secondarySystemBackground))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationBarItems(trailing: Button(action: {
            showingAddActivity = true
        }) {
            Image(systemName: "plus")
                .font(.title2)
        })
        .sheet(isPresented: $showingAddActivity) {
            AddActivityView(isPresented: $showingAddActivity, trip: trip)
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
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
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
                Circle()
                    .fill(Color.blue)
                    .frame(width: 10, height: 10)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
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
                        
                        Text("\(activity.participants.count) participants")
                            .font(.caption)
                            .foregroundColor(.secondary)
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
