//
//  ExpensesView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 3/7/25.
//

import Foundation
import SwiftUI

struct ExpensesView: View {
    let trip: Trip
    
    var body: some View {
        VStack {
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .padding(.bottom, 20)
            
            Text("This is the Expenses Page")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Here you will be able to track expenses and split costs with trip participants")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 8)
            
            Spacer()
        }
        .padding(.top, 60)
    }
}