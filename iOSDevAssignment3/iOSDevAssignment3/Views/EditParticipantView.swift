//
//  EditParticipantView.swift
//  iOSDevAssignment3
//
//  Created by Mallory Li on 13/5/2025.
//

import SwiftUI

struct EditParticipantView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    @Environment(\.presentationMode) var presentationMode

    let tripId: UUID
    @State var participant: Person
    
    @State private var name: String
    @State private var email: String

    init(tripId: UUID, participant: Person) {
        self.tripId = tripId
        self._participant = State(initialValue: participant)
        self._name = State(initialValue: participant.name)
        self._email = State(initialValue: participant.email)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Participant Details")) {
                    TextField("Name", text: $name)
                    TextField("Email (optional)", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
            }
            .navigationTitle("Edit Participant")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveParticipant()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }

    private func saveParticipant() {
        var updatedParticipant = participant
        updatedParticipant.name = name
        updatedParticipant.email = email
        tripViewModel.updateParticipant(in: tripId, person: updatedParticipant)
        presentationMode.wrappedValue.dismiss()
    }
}
