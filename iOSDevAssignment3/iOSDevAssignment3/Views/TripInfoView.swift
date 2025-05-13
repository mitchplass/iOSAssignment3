//
//  TripInfoView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 7/5/25.
//

import Foundation
import SwiftUI

struct TripInfoView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    let trip: Trip

    @State private var isEditingTripDetails: Bool = false
    @State private var editableName: String = ""
    @State private var editableDestination: String = ""
    @State private var editableStartDate: Date = Date()
    @State private var editableEndDate: Date = Date()

    @State private var showingAddParticipantSheet: Bool = false
    @State private var showingEditParticipantSheet: Bool = false
    @State private var participantToEdit: Person? = nil
    
    @State private var newParticipantNameForSheet: String = ""
    @State private var newParticipantEmailForSheet: String = ""
    
    @State private var showingDeleteParticipantConfirmation = false
    @State private var participantToDelete: Person? = nil

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Trip Details")) {
                    if isEditingTripDetails {
                        TextField("Trip Name", text: $editableName)
                        TextField("Destination", text: $editableDestination)
                        DatePicker("Start Date", selection: $editableStartDate, displayedComponents: .date)
                        DatePicker("End Date", selection: $editableEndDate, in: editableStartDate..., displayedComponents: .date)
                    } else {
                        InfoRow(label: "Trip Name", value: trip.name)
                        InfoRow(label: "Destination", value: trip.destination)
                        InfoRow(label: "Dates", value: DateHelper.formatDateRange(from: trip.startDate, to: trip.endDate))
                        InfoRow(label: "Duration", value: "\(trip.numberOfDays) days")
                    }
                }

                Section(header: Text("Participants")) {
                    if trip.participants.isEmpty && !isEditingTripDetails {
                        Text("No participants added yet.")
                            .foregroundColor(.gray)
                    }
                    
                    ForEach(trip.participants) { person in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(person.name)
                                if !person.email.isEmpty {
                                    Text(person.email)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            if isEditingTripDetails {
                                Button {
                                    participantToEdit = person
                                    showingEditParticipantSheet = true
                                } label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            if isEditingTripDetails {
                                Button(role: .destructive) {
                                    participantToDelete = person
                                    showingDeleteParticipantConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    
                    if isEditingTripDetails {
                        Button {
                            newParticipantNameForSheet = ""
                            newParticipantEmailForSheet = ""
                            showingAddParticipantSheet = true
                        } label: {
                            Label("Add Participant", systemImage: "plus.circle.fill")
                        }
                    }
                }
            }
            .navigationTitle(isEditingTripDetails ? "Edit Trip" : trip.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isEditingTripDetails {
                        Button("Cancel") {
                            cancelTripEditing()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isEditingTripDetails ? "Save" : "Edit") {
                        if isEditingTripDetails {
                            saveTripDetails()
                        } else {
                            startTripEditing()
                        }
                    }
                    .disabled(isEditingTripDetails && (editableName.isEmpty || editableDestination.isEmpty))
                }
            }
            .onAppear {
                if !isEditingTripDetails {
                    resetEditableTripFields()
                }
            }
            .onChange(of: trip) {
                 if !isEditingTripDetails {
                    resetEditableTripFields()
                }
            }
            .sheet(isPresented: $showingAddParticipantSheet) {
                AddParticipantView(
                    isPresented: $showingAddParticipantSheet,
                    name: $newParticipantNameForSheet,
                    email: $newParticipantEmailForSheet,
                    onAdd: {
                        if !newParticipantNameForSheet.isEmpty {
                            let newPerson = Person(name: newParticipantNameForSheet, email: newParticipantEmailForSheet)
                            tripViewModel.addParticipant(to: trip.id, person: newPerson)
                            newParticipantNameForSheet = ""
                            newParticipantEmailForSheet = ""
                        }
                    }
                )
            }
            .sheet(isPresented: $showingEditParticipantSheet) {
                if let participantToEdit = participantToEdit {
                    EditParticipantView(tripId: trip.id, participant: participantToEdit)
                        .environmentObject(tripViewModel)
                }
            }
            .alert("Delete Participant", isPresented: $showingDeleteParticipantConfirmation) {
                Button("Cancel", role: .cancel) { participantToDelete = nil }
                Button("Delete", role: .destructive) {
                    if let person = participantToDelete {
                        tripViewModel.deleteParticipant(from: trip.id, personId: person.id)
                        participantToDelete = nil
                    }
                }
            } message: {
                Text("Are you sure you want to delete \(participantToDelete?.name ?? "this participant")? This will also remove them from activities and adjust expenses.")
            }
        }
    }

    private func resetEditableTripFields() {
        editableName = trip.name
        editableDestination = trip.destination
        editableStartDate = trip.startDate
        editableEndDate = trip.endDate
    }

    private func startTripEditing() {
        resetEditableTripFields()
        isEditingTripDetails = true
    }

    private func cancelTripEditing() {
        isEditingTripDetails = false
    }

    private func saveTripDetails() {
        var updatedTrip = trip
        updatedTrip.name = editableName
        updatedTrip.destination = editableDestination
        updatedTrip.startDate = editableStartDate
        updatedTrip.endDate = editableEndDate

        tripViewModel.updateTrip(updatedTrip)
        isEditingTripDetails = false
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
