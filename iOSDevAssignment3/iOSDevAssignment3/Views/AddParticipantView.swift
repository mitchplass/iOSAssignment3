//
//  AddParticipantView.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation
import SwiftUI

struct AddParticipantView: View {
    @Binding var isPresented: Bool
    @Binding var name: String
    @Binding var email: String
    var onAdd: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    isPresented = false
                    name = ""
                    email = ""
                }
                .padding(.leading)
                
                Spacer()
                
                Text("Add Participant")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Add") {
                    onAdd()
                    isPresented = false
                }
                .disabled(name.isEmpty)
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
            
            VStack(spacing: 0) {
                TextField("Name", text: $name)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                
                Divider()
                
                TextField("Email (optional)", text: $email)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
            }
            .cornerRadius(10)
            .padding()
            
            Spacer()
        }
    }
}
