//
//  MultiSelectParticipantIDView.swift
//  iOSDevAssignment3
//
//  Created by Mallory Li on 11/5/2025.
//

import SwiftUI

struct MultiSelectParticipantIDView: View {
    let allParticipants: [Person]
    @Binding var selectedParticipantIDs: [Person.ID]
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(allParticipants) { person in
                    Button(action: {
                        toggleSelection(person.id)
                    }) {
                        HStack {
                            Text(person.name)
                            Spacer()
                            if selectedParticipantIDs.contains(person.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select Sharers")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    private func toggleSelection(_ personID: Person.ID) {
        if let index = selectedParticipantIDs.firstIndex(of: personID) {
            selectedParticipantIDs.remove(at: index)
        } else {
            selectedParticipantIDs.append(personID)
        }
    }
}
