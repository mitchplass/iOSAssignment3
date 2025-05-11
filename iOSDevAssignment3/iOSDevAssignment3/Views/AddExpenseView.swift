//
//  AddExpenseView.swift
//  iOSDevAssignment3
//
//  Created by Mallory Li on 11/5/2025.
//

import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    @Binding var isPresented: Bool
    let trip: Trip // The trip to add the expense to

    @State private var title: String = ""
    @State private var amountString: String = ""
    @State private var date: Date = Date()
    @State private var paidBy: Person.ID? = nil // Store ID
    @State private var selectedSplitAmongIDs: [Person.ID] = [] // Store IDs
    @State private var category: ExpenseCategory = .other
    @State private var notes: String = ""

    @State private var showingParticipantSheetForPaidBy = false
    @State private var showingParticipantSheetForSplitAmong = false
    
    @State private var isSplitUnequally: Bool = false
    @State private var customAmountsInput: [Person.ID: String] = [:] // String for TextField input

    var availableParticipants: [Person] {
        trip.participants
    }

    private var isValidForm: Bool {
        !title.isEmpty && Double(amountString) != nil && paidBy != nil && !selectedSplitAmongIDs.isEmpty && validateCustomSplitLogic() == nil
    }
    
    private func personName(for id: Person.ID?) -> String? {
        guard let personId = id else { return nil }
        return availableParticipants.first { $0.id == personId }?.name
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Title (e.g., Dinner)", text: $title)
                    HStack {
                        Text("$") // Currency symbol
                        TextField("Amount", text: $amountString)
                            .keyboardType(.decimalPad)
                    }
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { cat in
                            HStack {
                                Image(systemName: cat.icon)
                                Text(cat.rawValue.capitalized)
                            }.tag(cat)
                        }
                    }
                }

                Section(header: Text("Payment & Sharing")) {
                    // Paid By Picker
                    Picker("Paid By", selection: $paidBy) {
                        Text("Select Payer").tag(nil as Person.ID?)
                        ForEach(availableParticipants) { person in
                            Text(person.name).tag(person.id as Person.ID?)
                        }
                    }

                    // Shared Among Multi-selector
                    NavigationLink(destination: MultiSelectParticipantIDView(
                        allParticipants: availableParticipants,
                        selectedParticipantIDs: $selectedSplitAmongIDs
                    )) {
                        HStack {
                            Text("Shared With")
                            Spacer()
                            Text(selectedSplitAmongIDs.isEmpty ? "Select Sharers" : "\(selectedSplitAmongIDs.count) selected")
                                .foregroundColor(selectedSplitAmongIDs.isEmpty ? .gray : .accentColor)
                        }
                    }
                }
                
                Section(header: Text("Split Method")) {
                    Toggle("Split unequally?", isOn: $isSplitUnequally.animation())
                    
                    if isSplitUnequally && !selectedSplitAmongIDs.isEmpty {
                        Text("Enter custom amounts for each person who shared:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        ForEach(selectedSplitAmongIDs, id: \.self) { personID in
                            if let person = availableParticipants.first(where: { $0.id == personID }) {
                                HStack {
                                    Text(person.name)
                                    Spacer()
                                    TextField("Amount", text: Binding(
                                        get: { customAmountsInput[personID] ?? "" },
                                        set: { customAmountsInput[personID] = $0 }
                                    ))
                                    .keyboardType(.decimalPad)
                                    .frame(width: 80)
                                    .multilineTextAlignment(.trailing)
                                }
                            }
                        }
                        if let validationError = validateCustomSplitLogic() {
                            Text(validationError)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    } else if isSplitUnequally && selectedSplitAmongIDs.isEmpty {
                        Text("Select sharers first to set custom amounts.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                Section(header: Text("Optional Details")) {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...)
                    Button("Add Receipt (Future Feature)") {
                        // Placeholder for receipt functionality
                    }
                    .foregroundColor(.gray)
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addExpense()
                    }
                    .disabled(!isValidForm)
                }
            }
        }
    }
    
    private func validateCustomSplitLogic() -> String? {
        guard isSplitUnequally else { return nil } // No validation if not splitting unequally
        guard !selectedSplitAmongIDs.isEmpty else { return "Select sharers for custom split."} // Should not happen if UI is correct
        
        let totalExpenseAmount = Double(amountString) ?? 0.0
        if totalExpenseAmount == 0 { return "Total expense amount must be greater than zero."}

        var currentSplitSum: Double = 0
        var hasEmptyCustomAmount = false
        for personID in selectedSplitAmongIDs {
            guard let amountStr = customAmountsInput[personID], !amountStr.isEmpty, let amountVal = Double(amountStr) else {
                hasEmptyCustomAmount = true
                break
            }
            if amountVal < 0 { return "Custom amounts cannot be negative." }
            currentSplitSum += amountVal
        }

        if hasEmptyCustomAmount {
            return "All selected sharers must have a custom amount."
        }

        if abs(currentSplitSum - totalExpenseAmount) > 0.01 { // Tolerance for floating point
            return "Custom amounts sum (\(String(format: "%.2f", currentSplitSum))) must equal total expense (\(String(format: "%.2f", totalExpenseAmount)))."
        }
        return nil // Valid
    }

    private func addExpense() {
        guard let finalAmount = Double(amountString), let finalPaidBy = paidBy else { return }

        var finalCustomSplitAmounts: [Person.ID: Double]? = nil
        if isSplitUnequally {
            // Ensure all selected sharers have valid double inputs for custom amounts
            var tempCustomAmounts: [Person.ID: Double] = [:]
            for id in selectedSplitAmongIDs {
                guard let amountStr = customAmountsInput[id], let amountVal = Double(amountStr) else {
                    // This should ideally be caught by validation, but as a safeguard
                    print("Error: Invalid custom amount string for \(personName(for: id) ?? "Unknown")")
                    return
                }
                tempCustomAmounts[id] = amountVal
            }
            finalCustomSplitAmounts = tempCustomAmounts
        }

        let newExpense = Expense(
            title: title,
            amount: finalAmount,
            date: date,
            paidBy: finalPaidBy,
            splitAmong: selectedSplitAmongIDs,
            category: category,
            notes: notes.isEmpty ? nil : notes,
            receiptImageURL: nil, // Implement later
            customSplitAmounts: finalCustomSplitAmounts
        )
        tripViewModel.addExpense(to: trip.id, expense: newExpense)
        isPresented = false
    }
}
