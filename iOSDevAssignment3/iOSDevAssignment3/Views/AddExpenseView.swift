//
//  AddExpenseView.swift
//  iOSDevAssignment3
//
//  Created by Mallory Li on 11/5/2025.
//

import SwiftUI
import PhotosUI

struct AddExpenseView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    @Binding var isPresented: Bool
    let trip: Trip
    var expenseToEdit: Expense?

    @State private var title: String = ""
    @State private var amountString: String = ""
    @State private var date: Date = Date()
    @State private var paidBy: Person.ID?
    @State private var selectedSplitAmongIDs: [Person.ID] = []
    @State private var category: ExpenseCategory = .other
    @State private var notes: String = ""
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var displayedReceiptImage: Image? = nil
    @State private var actualReceiptImageData: Data? = nil

    @State private var isSplitUnequally: Bool = false
    @State private var customAmountsInput: [Person.ID: String] = [:]
    
    var formTitle: String {
        expenseToEdit == nil ? "Add New Expense" : "Edit Expense"
    }

    var availableParticipants: [Person] {
        trip.participants
    }
    
    var formIsValid: Bool {
        guard !title.isEmpty,
              let _ = Double(amountString),
              paidBy != nil,
              !selectedSplitAmongIDs.isEmpty else {
            return false
        }
        if isSplitUnequally {
            return validateCustomSplitLogic() == nil
        }
        return true
    }
    
    init(isPresented: Binding<Bool>, trip: Trip, expenseToEdit: Expense? = nil) {
        self._isPresented = isPresented
        self.trip = trip
        self.expenseToEdit = expenseToEdit

        if let expense = expenseToEdit {
            _title = State(initialValue: expense.title)
            _amountString = State(initialValue: String(format: "%.2f", expense.amount))
            _date = State(initialValue: expense.date)
            _paidBy = State(initialValue: expense.paidBy)
            _selectedSplitAmongIDs = State(initialValue: expense.splitAmong)
            _category = State(initialValue: expense.category)
            _notes = State(initialValue: expense.notes ?? "")
            
            if let customSplits = expense.customSplitAmounts, !customSplits.isEmpty {
                _isSplitUnequally = State(initialValue: true)
                var initialCustomInputs: [Person.ID: String] = [:]
                for (id, amount) in customSplits {
                    initialCustomInputs[id] = String(format: "%.2f", amount)
                }
                _customAmountsInput = State(initialValue: initialCustomInputs)
            } else {
                 _isSplitUnequally = State(initialValue: false)
                 _customAmountsInput = State(initialValue: [:])
            }

            if let imageData = expense.receiptImageData {
                _actualReceiptImageData = State(initialValue: imageData)
                if let uiImage = UIImage(data: imageData) {
                    _displayedReceiptImage = State(initialValue: Image(uiImage: uiImage))
                }
            }

        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Title (e.g. dinner at tripsync hq)", text: $title)
                    HStack {
                        Text(Locale.current.currencySymbol ?? "$")
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
                    Picker("Paid By", selection: $paidBy) {
                        Text("Select Payer").tag(nil as Person.ID?)
                        ForEach(availableParticipants) { person in
                            Text(person.name).tag(person.id as Person.ID?)
                        }
                    }

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
                    .onChange(of: selectedSplitAmongIDs, initial: false) { oldValue, newValue in
                        if isSplitUnequally {
                            let newSelectedSet = Set(newValue)
                            customAmountsInput = customAmountsInput.filter { newSelectedSet.contains($0.key) }
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
                                .padding(.top, 2)
                        }
                    } else if isSplitUnequally && selectedSplitAmongIDs.isEmpty {
                        Text("Please select sharers first to set custom amounts.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                Section(header: Text("Optional Details")) {
                    TextField("Notes (e.g. Amy ate nothing.)", text: $notes, axis: .vertical)
                        .lineLimit(3...)
                }
                
                Section(header: Text("Receipt Photo")) {
                    if let displayedReceiptImage {
                        displayedReceiptImage
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    self.selectedPhotoItem = nil
                                    self.displayedReceiptImage = nil
                                    self.actualReceiptImageData = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.gray.opacity(0.8))
                                        .background(Circle().fill(Color.white.opacity(0.6)))
                                }
                                .padding(5)
                            }
                    }

                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Label(displayedReceiptImage == nil ? "Add Receipt Photo" : "Change Receipt Photo", systemImage: "photo.on.rectangle.angled")
                    }
                    .onChange(of: selectedPhotoItem) {
                        Task {
                            if let data = try? await selectedPhotoItem?.loadTransferable(type: Data.self) {
                                actualReceiptImageData = data
                                if let uiImage = UIImage(data: data) {
                                    displayedReceiptImage = Image(uiImage: uiImage)
                                }
                            } else {
                                actualReceiptImageData = nil
                                displayedReceiptImage = nil
                                print("Failed to load image data or no item selected.")
                            }
                        }
                    }
                }
            }
            .navigationTitle(formTitle)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(expenseToEdit == nil ? "Add" : "Save Changes") {
                        saveExpense()
                    }
                    .disabled(!formIsValid)
                }
            }
        }
    }
    
    private func validateCustomSplitLogic() -> String? {
        guard isSplitUnequally else { return nil }
        guard !selectedSplitAmongIDs.isEmpty else { return "Select sharers for custom split."}
        
        let totalExpenseAmount = Double(amountString) ?? 0.0
        if totalExpenseAmount <= 0 { return "Total expense amount must be greater than zero."}

        var currentSplitSum: Double = 0
        var hasEmptyOrInvalidCustomAmount = false
        for personID in selectedSplitAmongIDs {
            guard let amountStr = customAmountsInput[personID], !amountStr.isEmpty, let amountVal = Double(amountStr) else {
                hasEmptyOrInvalidCustomAmount = true; break
            }
            if amountVal < 0 { return "Custom amounts cannot be negative." }
            currentSplitSum += amountVal
        }

        if hasEmptyOrInvalidCustomAmount { return "All selected sharers must have a valid custom amount." }

        if abs(currentSplitSum - totalExpenseAmount) > 0.01 {
            return "Custom amounts sum (\(currentSplitSum.formatted(.currency(code: "AUD")))) must equal total expense (\(totalExpenseAmount.formatted(.currency(code: "AUD"))))."
        }
        return nil
    }

    private func saveExpense() {
        guard let finalAmount = Double(amountString), let finalPaidBy = paidBy else {
            print("Form data invalid for submission.")
            return
        }

        var finalCustomSplitAmounts: [Person.ID: Double]? = nil
        if isSplitUnequally {
            var tempCustomAmounts: [Person.ID: Double] = [:]
            var allValid = true
            for id in selectedSplitAmongIDs {
                guard let amountStr = customAmountsInput[id], let amountVal = Double(amountStr) else {
                    allValid = false; break
                }
                tempCustomAmounts[id] = amountVal
            }
            guard allValid else { print("Error: Invalid amount during submission."); return }
            finalCustomSplitAmounts = tempCustomAmounts.isEmpty ? nil : tempCustomAmounts
        }

        if var existingExpense = expenseToEdit {
            existingExpense.title = title
            existingExpense.amount = finalAmount
            existingExpense.date = date
            existingExpense.paidBy = finalPaidBy
            existingExpense.splitAmong = selectedSplitAmongIDs
            existingExpense.category = category
            existingExpense.notes = notes.isEmpty ? nil : notes
            existingExpense.receiptImageData = actualReceiptImageData
            existingExpense.customSplitAmounts = finalCustomSplitAmounts
            
            tripViewModel.updateExpense(in: trip.id, expense: existingExpense)
        } else {
            let newExpense = Expense(
                title: title,
                amount: finalAmount,
                date: date,
                paidBy: finalPaidBy,
                splitAmong: selectedSplitAmongIDs,
                category: category,
                notes: notes.isEmpty ? nil : notes,
                receiptImageData: actualReceiptImageData,
                customSplitAmounts: finalCustomSplitAmounts
            )
            tripViewModel.addExpense(to: trip.id, expense: newExpense)
        }
        isPresented = false
    }
}
