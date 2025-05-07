//
//  TripInfoView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 3/7/25.
//

import Foundation
import SwiftUI

struct TripInfoView: View {
    let trip: Trip
    
    var body: some View {
        VStack {
            Image(systemName: "info.circle")
                .font(.system(size: 60))
                .foregroundColor(.purple)
                .padding(.bottom, 20)
            
            Text("This is the Trip Info Page")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Here you will be able to view and edit general information about your trip")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 16) {
                InfoRow(label: "Trip Name", value: trip.name)
                InfoRow(label: "Destination", value: trip.destination.name)
                InfoRow(label: "Dates", value: formatDateRange(from: trip.startDate, to: trip.endDate))
                InfoRow(label: "Duration", value: "\(trip.numberOfDays) days")
                InfoRow(label: "Participants", value: "\(trip.participants.count) people")
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .padding()
            
            Spacer()
        }
        .padding(.top, 40)
    }
    
    private func formatDateRange(from startDate: Date, to endDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        return "\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))"
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .fontWeight(.medium)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}
