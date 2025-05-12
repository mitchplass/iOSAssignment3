//
//  AddItemView.swift
//  iOSDevAssignment3
//
//  Created by Mallory Li on 11/5/2025.
//

import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    @Binding var isPresented: Bool
    let trip: Trip
    var itemToEdit: Item?

    @State private var itemName: String = ""
    @State private var quantity: Int = 1
    @State private var selectedAssigneeID: Person.ID?
    @State private var category: String = "General"
    @State private var isShared: Bool = true
    @State private var status: ItemStatus = .needed
    
    let commonCategories = ["General", "Clothing", "Toiletries", "Documents", "Electronics", "Medication", "Camping Gear", "Food & Drinks"]
    @State private var newCategory: String = ""
    @State private var showingAddCategoryAlert = false

    var formTitle: String {
        itemToEdit == nil ? "Add New Item" : "Edit Item"
    }

    var availableParticipants: [Person] {
        trip.participants
    }
    
    var filteredCategories: [String] {
        var categories = commonCategories
        if let currentItemCategory = itemToEdit?.category, !commonCategories.contains(currentItemCategory) {
            categories.append(currentItemCategory)
        }
        if !category.isEmpty && !categories.contains(category) { // If a new category was just typed/set
            categories.append(category)
        }
        return categories.filter { !$0.isEmpty }.sorted()
    }

    init(isPresented: Binding<Bool>, trip: Trip, itemToEdit: Item? = nil) {
        self._isPresented = isPresented
        self.trip = trip
        self.itemToEdit = itemToEdit

        if let item = itemToEdit {
            _itemName = State(initialValue: item.name)
            _quantity = State(initialValue: item.quantity)
            _selectedAssigneeID = State(initialValue: item.assignedTo)
            _category = State(initialValue: item.category ?? "General")
            _isShared = State(initialValue: item.isShared)
            _status = State(initialValue: item.status)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    TextField("Item Name (e.g., Tent, Toothbrush)", text: $itemName)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
                }

                Section(header: Text("Category & Type")) {
                    Picker("Category", selection: $category) {
                        ForEach(filteredCategories, id: \.self) { catName in
                            Text(catName).tag(catName)
                        }
                    }
                    Button("Add New Category") {
                        newCategory = "" // Reset before showing
                        showingAddCategoryAlert = true
                    }
                    
                    Toggle("Shared Item (for the group)", isOn: $isShared)
                }

                Section(header: Text("Assignment & Status")) {
                    Picker("Assign To", selection: $selectedAssigneeID) {
                        Text("Unassigned").tag(nil as Person.ID?)
                        ForEach(availableParticipants) { person in
                            Text(person.name).tag(person.id as Person.ID?)
                        }
                    }
                    
                    if itemToEdit != nil {
                        Picker("Status", selection: $status) {
                            ForEach(ItemStatus.allCases) { statValue in
                                Text(statValue.displayName).tag(statValue)
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
                    Button(itemToEdit == nil ? "Add" : "Save") {
                        saveItem()
                    }
                    .disabled(itemName.isEmpty)
                }
            }
            .alert("Add New Category", isPresented: $showingAddCategoryAlert) {
                TextField("Category Name", text: $newCategory)
                Button("Add") {
                    if !newCategory.isEmpty {
                        self.category = newCategory.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    newCategory = ""
                }
                Button("Cancel", role: .cancel) { newCategory = "" }
            }
        }
    }

    private func saveItem() {
        let finalCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        let categoryToSave = finalCategory.isEmpty ? "General" : finalCategory

        if var existingItem = itemToEdit {
            existingItem.name = itemName
            existingItem.quantity = quantity
            existingItem.assignedTo = selectedAssigneeID
            existingItem.category = categoryToSave
            existingItem.isShared = isShared
            existingItem.status = status
            tripViewModel.updateItem(in: trip.id, item: existingItem)
        } else {
            let newItem = Item(
                name: itemName,
                quantity: quantity,
                assignedTo: selectedAssigneeID,
                status: .needed,
                category: categoryToSave,
                isShared: isShared
            )
            tripViewModel.addItem(to: trip.id, item: newItem)
        }
        isPresented = false
    }
}
