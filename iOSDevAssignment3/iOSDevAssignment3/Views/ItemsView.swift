//
//  ItemsView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 7/5/25.
//

import SwiftUI

struct ItemsView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    let trip: Trip
    
    var onEditItem: (Item) -> Void

    @State private var selectedItemListType: ItemListType = .shared
    
    enum ItemListType: String, CaseIterable, Identifiable {
        case shared = "Shared List"
        case personal = "My Personal Items"
        var id: String { self.rawValue }
    }

    private var categorizedItems: [String: [Item]] {
        let itemsToShow = trip.items.filter {
            selectedItemListType == .shared ? $0.isShared : !$0.isShared
        }
        return Dictionary(grouping: itemsToShow, by: { $0.category ?? "Uncategorized" })
    }
    
    private var sortedCategories: [String] {
        categorizedItems.keys.sorted()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Packing Checklist")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 10)

            Picker("List Type", selection: $selectedItemListType) {
                ForEach(ItemListType.allCases) { type in Text(type.rawValue).tag(type) }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .padding(.bottom, 5)

            let currentItems = trip.items.filter { selectedItemListType == .shared ? $0.isShared : !$0.isShared }
            if currentItems.isEmpty {
                noItemsView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(sortedCategories, id: \.self) { categoryName in
                        Section(header: Text(categoryName).font(.headline)) {
                            ForEach(categorizedItems[categoryName] ?? []) { item in
                                ItemRowView(
                                    itemState: itemBinding(for: item),
                                    trip: trip,
                                    onEditTap: { self.onEditItem(item) }
                                )
                            }
                            .onDelete { offsets in deleteItems(at: offsets, inCategory: categoryName) }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }
    
    private func itemBinding(for item: Item) -> Binding<Item> {
        guard let tripIndex = tripViewModel.trips.firstIndex(where: { $0.id == trip.id }),
              let itemIndex = tripViewModel.trips[tripIndex].items.firstIndex(where: { $0.id == item.id }) else {
            fatalError("Item or Trip not found for binding.")
        }
        return Binding(get: {tripViewModel.trips[tripIndex].items[itemIndex]}, set: {tripViewModel.updateItem(in: trip.id, item: $0)})
    }

    private func deleteItems(at offsets: IndexSet, inCategory category: String) {
        guard let itemsInCategory = categorizedItems[category] else { return }
        let itemsToDelete = offsets.map { itemsInCategory[$0] }
        itemsToDelete.forEach { tripViewModel.deleteItem(from: trip.id, itemId: $0.id) }
    }

    private var noItemsView: some View {
        VStack {
            Spacer()
            Image(systemName: selectedItemListType == .shared ? "list.bullet.clipboard" : "person.crop.rectangle.stack").font(.system(size: 50)).foregroundColor(.gray).padding(.bottom)
            Text("No \(selectedItemListType == .shared ? "Shared" : "Personal") Items Yet").font(.title2).fontWeight(.semibold)
            Text("Use the '+' button above to add items.").font(.subheadline).foregroundColor(.gray)
            Spacer()
        }.padding(.horizontal)
    }
}

struct ItemRowView: View {
    @Binding var itemState: Item
    let trip: Trip
    var onEditTap: () -> Void

    private func personName(for id: Person.ID?) -> String? {
        guard let personId = id else { return nil }
        return trip.participants.first { $0.id == personId }?.name
    }

    var body: some View {
        HStack {
            Button {
                switch itemState.status {
                case .needed: itemState.status = .packed
                case .packed: itemState.status = .purchased
                case .purchased: itemState.status = .needed
                }
            } label: { Image(systemName: itemState.status.systemImage).foregroundColor(itemState.status == .packed ? .green : (itemState.status == .purchased ? .blue : .gray)).font(.title2) }
            .buttonStyle(BorderlessButtonStyle())

            VStack(alignment: .leading) {
                Text(itemState.name).strikethrough(itemState.status == .packed || itemState.status == .purchased, color: .gray).font(.headline)
                HStack(spacing: 4) {
                    if itemState.quantity > 1 { Text("Qty: \(itemState.quantity)") }
                    if let assigneeName = personName(for: itemState.assignedTo) {
                        if itemState.quantity > 1 { Text("·").foregroundColor(.gray) }; Image(systemName: "person.fill").foregroundColor(.blue); Text(assigneeName)
                    } else if itemState.isShared {
                        if itemState.quantity > 1 { Text("·").foregroundColor(.gray) }; Text("Unassigned")
                    }
                }.font(.caption).foregroundColor(.secondary)
            }
            Spacer()
            Button { onEditTap() } label: { Image(systemName: "pencil.circle").foregroundColor(.accentColor) }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
        .contextMenu { Button { onEditTap() } label: { Label("Edit Item", systemImage: "pencil") } }
    }
}
