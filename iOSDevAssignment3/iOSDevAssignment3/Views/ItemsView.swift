//
//  ItemsView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 3/7/25.
//

import Foundation
import SwiftUI

struct ItemsView: View {
    let trip: Trip
    
    var body: some View {
        VStack {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text("This is the Items Page")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Here you will be able to create and manage packing lists for your trip")
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