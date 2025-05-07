//
//  NewTripView.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation
import SwiftUI

struct NewTripView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    @Binding var showingNewTripView: Bool
    
    @State private var name = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(60 * 60 * 24 * 6)
    @State private var participants: [Person] = [Person(name: "Me", email: "")]
    @State private var showingAddParticipant = false
    @State private var newParticipantName = ""
    @State private var newParticipantEmail = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    showingNewTripView = false
                }
                .padding(.leading)
                
                Spacer()
                
                Text("New Trip")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Create") {
                    createTrip()
                }
                .disabled(name.isEmpty || destination.isEmpty || participants.isEmpty)
                .padding(.trailing)
            }
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(UIColor.separator))
                    .offset(y: 12),
                alignment: .bottom
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Trip Details")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            TextField("Trip Name", text: $name)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                            
                            Divider()
                            
                            TextField("Destination", text: $destination)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                        }
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Dates")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                            
                            Divider()
                            
                            DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                        }
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Participants")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            ForEach(participants) { participant in
                                HStack {
                                    Text(participant.name)
                                    Spacer()
                                    if !participant.email.isEmpty {
                                        Text(participant.email)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .contextMenu {
                                    Button(role: .destructive, action: {
                                        if let index = participants.firstIndex(where: { $0.id == participant.id }) {
                                            participants.remove(at: index)
                                        }
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                
                                if participant.id != participants.last?.id {
                                    Divider()
                                }
                            }
                            
                            Button(action: {
                                showingAddParticipant = true
                            }) {
                                HStack {
                                    Label("Add Participant", systemImage: "person.badge.plus")
                                    Spacer()
                                }
                                .padding()
                                .foregroundColor(.blue)
                                .background(Color(UIColor.secondarySystemBackground))
                            }
                        }
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .sheet(isPresented: $showingAddParticipant) {
            AddParticipantView(
                isPresented: $showingAddParticipant,
                name: $newParticipantName,
                email: $newParticipantEmail,
                onAdd: {
                    if !newParticipantName.isEmpty {
                        participants.append(Person(name: newParticipantName, email: newParticipantEmail))
                        newParticipantName = ""
                        newParticipantEmail = ""
                    }
                }
            )
        }
    }
    
    private func createTrip() {
        let newTrip = Trip(
            name: name,
            destination: Destination(name: destination),
            startDate: startDate,
            endDate: endDate,
            participants: participants,
            activities: [],
            items: [],
            expenses: []
        )
        
        tripViewModel.addTrip(newTrip)
        tripViewModel.currentTrip = newTrip
        showingNewTripView = false
    }
}
