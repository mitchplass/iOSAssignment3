//
//  TripDetailView.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // need it for the protocol
    }
}

struct TripDetailView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    let trip: Trip
    @State private var selectedTab = 0
    @State private var showingAddActivitySheet = false
    @State private var showingAddItemSheet = false
    @State private var showingAddExpenseSheet = false
    @State private var showingExportOptions = false
    @State private var showingShareSheet = false
    @State private var calendarFileURL: URL?

    @State private var itemToEdit: Item? = nil
    @State private var expenseToEdit: Expense? = nil
    @State private var dateForNewActivity: Date?


    var body: some View {
        TabView(selection: $selectedTab) {
            TimetableView(
                trip: trip,
                currentSelectedDateFromTimetable: $dateForNewActivity
            )
                .tabItem { Label("Timetable", systemImage: "calendar") }.tag(0)
            
            DestinationView(destination: trip.destination)
                .tabItem { Label("Destination", systemImage: "map") }.tag(1)
            
            ItemsView(
                trip: trip,
                onEditItem: { item in
                    self.itemToEdit = item
                    self.showingAddItemSheet = true
                }
            )
                .tabItem { Label("Items", systemImage: "checklist") }.tag(2)
            
            ExpensesView(
                trip: trip,
                onEditExpense: { expense in
                    self.expenseToEdit = expense
                    self.showingAddExpenseSheet = true
                }
            )
                .tabItem { Label("Expenses", systemImage: "dollarsign.circle") }.tag(3)

            TripInfoView(trip: trip)
                .tabItem { Label("Info", systemImage: "info.circle") }.tag(4)
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                switch selectedTab {
                case 0:
                    Button {
                        self.dateForNewActivity = self.dateForNewActivity ?? trip.startDate
                        self.showingAddActivitySheet = true
                    } label: { Image(systemName: "plus.circle.fill") }
                case 2:
                    Button {
                        self.itemToEdit = nil
                        self.showingAddItemSheet = true
                    } label: { Image(systemName: "plus.circle.fill") }
                case 3:
                    Button {
                        self.expenseToEdit = nil
                        self.showingAddExpenseSheet = true
                    } label: { Image(systemName: "plus.circle.fill") }
                case 4:
                    Button {
                        showingExportOptions = true
                    } label: { Image(systemName: "square.and.arrow.up") }
                default:
                    EmptyView()
                }
            }
        }
        .sheet(isPresented: $showingAddActivitySheet) {
            ActivityFormView(isPresented: $showingAddActivitySheet, trip: trip, activityDate: dateForNewActivity ?? trip.startDate)
        }
        .sheet(isPresented: $showingAddItemSheet) {
            AddItemView(isPresented: $showingAddItemSheet, trip: trip, itemToEdit: itemToEdit)
        }
        .sheet(isPresented: $showingAddExpenseSheet) {
            AddExpenseView(isPresented: $showingAddExpenseSheet, trip: trip, expenseToEdit: expenseToEdit)
        }
        .confirmationDialog("Export Itinerary", isPresented: $showingExportOptions) {
            Button("Export to Calendar") {
                exportToCalendar()
            }
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let fileURL = calendarFileURL {
                ShareSheet(items: [fileURL])
            }
        }
    }

    private func exportToCalendar() {
        let iCalContent = ICalendarGenerator.generateICalendar(for: trip)

        if let fileURL = ICalendarGenerator.saveToTemporaryFile(
            content: iCalContent,
            fileName: "\(trip.name.replacingOccurrences(of: " ", with: "_"))_Itinerary.ics"
        ) {
            calendarFileURL = fileURL
            showingShareSheet = true
        }
    }
}
