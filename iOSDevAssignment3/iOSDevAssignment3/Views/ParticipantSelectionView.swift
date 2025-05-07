//
//  ParticipantSelectionView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 3/7/25.
//

import Foundation
import SwiftUI

struct ParticipantSelectionView: View {
    let allParticipants: [Person]
    @Binding var selectedParticipants: [Person]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(allParticipants) { person in
                    Button(action: {
                        toggleParticipant(person)
                    }) {
                        HStack {
                            Text(person.name)
                            Spacer()
                            if isSelected(person) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Select Participants")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func isSelected(_ person: Person) -> Bool {
        selectedParticipants.contains { $0.id == person.id }
    }
    
    private func toggleParticipant(_ person: Person) {
        if isSelected(person) {
            selectedParticipants.removeAll { $0.id == person.id }
        } else {
            selectedParticipants.append(person)
        }
    }
}