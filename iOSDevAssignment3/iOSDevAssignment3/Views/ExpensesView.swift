//
//  ExpensesView.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 3/7/25.
//

import Foundation
import SwiftUI

struct ExpensesView: View {
    @EnvironmentObject var tripViewModel: TripViewModel
    let trip: Trip
    
    var onEditExpense: (Expense) -> Void
    
    @State private var showingReceiptImageSheet = false
    @State private var receiptImageToShow: Data? = nil


    var body: some View {
        VStack(spacing: 0) {
            if trip.expenses.isEmpty {
                if #available(iOS 17.0, *) {
                    ContentUnavailableView("No Expenses Logged", systemImage: "creditcard.trianglebadge.exclamationmark", description: Text("Tap '+' in the toolbar to add the first expense."))
                } else {
                    VStack {
                        Spacer(); Image(systemName: "creditcard.trianglebadge.exclamationmark").font(.system(size: 50)).foregroundColor(.gray).padding(.bottom)
                        Text("No Expenses Logged").font(.title2).fontWeight(.semibold)
                        Text("Tap '+' in the toolbar to add the first expense.").font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal)
                        Spacer()
                    }
                }
            } else {
                ExpenseSummaryHeaderView(trip: trip).padding([.horizontal, .top]).padding(.bottom, 8)
                List {
                    ForEach(trip.expenses.sorted(by: { $0.date > $1.date })) { expense in
                        ExpenseRow(expense: expense, tripParticipants: trip.participants)
                            .contentShape(Rectangle())
                            .onTapGesture { onEditExpense(expense) }
                            .contextMenu {
                                Button { onEditExpense(expense) } label: { Label("Edit Expense", systemImage: "pencil") }
                                
                                if expense.receiptImageData != nil {
                                    Button {
                                        receiptImageToShow = expense.receiptImageData
                                        showingReceiptImageSheet = true
                                    } label: {
                                        Label("View Receipt", systemImage: "doc.richtext.fill")
                                    }
                                }
                                
                                Button(role: .destructive) { tripViewModel.deleteExpense(from: trip.id, expenseId: expense.id) } label: { Label("Delete Expense", systemImage: "trash") }
                            }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .sheet(isPresented: $showingReceiptImageSheet) {
            if let data = receiptImageToShow, let uiImage = UIImage(data: data) {
                VStack {
                    Text("Receipt")
                        .font(.title2).padding()
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .padding()
                    Spacer()
                    Button("Done") { showingReceiptImageSheet = false }
                        .padding()
                }
            } else {
                Text("Could not load receipt image.")
            }
        }
    }
}

struct ExpenseRow: View {
    let expense: Expense
    let tripParticipants: [Person]

    private func personName(for id: Person.ID?) -> String {
        guard let personId = id, let person = tripParticipants.first(where: { $0.id == personId }) else {
            return "Unknown"
        }
        return person.name
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: expense.category.icon)
                    .foregroundColor(categoryColor(expense.category))
                    .font(.title3)
                Text(expense.title)
                    .font(.headline)
                Spacer()
                if expense.receiptImageData != nil {
                    Image(systemName: "doc.richtext.fill")
                        .foregroundColor(.blue)
                        .padding(.trailing, 4)
                }
                Text(expense.amount.formatted(.currency(code: "AUD")))
                    .font(.headline)
                    .fontWeight(.medium)
            }

            Text("Paid by: \(personName(for: expense.paidBy)) on \(expense.date, style: .date)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            let sharerCount = expense.numberOfSharers
            if let customSplit = expense.customSplitAmounts, !customSplit.isEmpty {
                Text("Split unequally among \(sharerCount) person\(sharerCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else if sharerCount > 0 {
                let amountPerPerson = expense.amount / Double(sharerCount)
                Text("Shared among \(sharerCount) (\(amountPerPerson.formatted(.currency(code: "AUD")))/person)")
                    .font(.caption)
                    .foregroundColor(.gray)
            } else {
                Text("Not shared with anyone yet.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            if let notes = expense.notes, !notes.isEmpty {
                Text("Note: \(notes)")
                    .font(.caption)
                    .italic()
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 5)
    }

    private func categoryColor(_ category: ExpenseCategory) -> Color {
        switch category {
        case .accommodation: return .blue
        case .transportation: return .green
        case .food: return .orange
        case .activities: return .purple
        case .other: return .gray
        }
    }
}

struct ExpenseSummaryHeaderView: View {
    let trip: Trip

    private var netBalances: [(person: Person, balance: Double)] {
        var balances: [Person.ID: Double] = [:]
        trip.participants.forEach { balances[$0.id] = 0.0 }

        for expense in trip.expenses {
            balances[expense.paidBy, default: 0.0] += expense.amount

            let totalSharers = expense.numberOfSharers
            if totalSharers > 0 {
                for sharerId in expense.splitAmong {
                    let amountOwed = expense.amountOwedBy(sharerId, totalParticipantsInSplit: totalSharers, tripParticipants: trip.participants)
                    balances[sharerId, default: 0.0] -= amountOwed
                }
            }
        }
        
        return balances.compactMap { personID, balance -> (Person, Double)? in
            guard let person = trip.participants.first(where: { $0.id == personID }) else { return nil }
            return (person, balance)
        }.sorted { $0.person.name.lowercased() < $1.person.name.lowercased() }
    }
    
    private var settlementSuggestions: [String] {
        var suggestions: [String] = []
        var balancesToSettle = netBalances.filter { abs($0.balance) > 0.01 }

        while true {
            balancesToSettle.sort { ($0.balance, $0.person.name) < ($1.balance, $1.person.name) }
            
            guard let ower = balancesToSettle.first(where: { $0.balance < -0.009 }),
                  let owedPerson = balancesToSettle.last(where: { $0.balance > 0.009 }) else {
                break
            }

            let amountToSettle = min(abs(ower.balance), owedPerson.balance)

            if amountToSettle > 0.01 {
                 suggestions.append("\(ower.person.name) pays \(owedPerson.person.name): \(amountToSettle.formatted(.currency(code: "AUD")))")
            }

            if let owerIndex = balancesToSettle.firstIndex(where: { $0.person.id == ower.person.id }) {
                balancesToSettle[owerIndex].balance += amountToSettle
            }
            if let owedPersonIndex = balancesToSettle.firstIndex(where: { $0.person.id == owedPerson.person.id }) {
                balancesToSettle[owedPersonIndex].balance -= amountToSettle
            }
            balancesToSettle.removeAll(where: { abs($0.balance) < 0.01 })
        }
        
        if suggestions.isEmpty && !trip.expenses.isEmpty && netBalances.allSatisfy({ abs($0.balance) < 0.01 }) {
             return ["All expenses are balanced :)!"]
        } else if suggestions.isEmpty && !trip.expenses.isEmpty {
            return ["No clear one-to-one settlements. Review balances."]
        }
        return suggestions
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Summary")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 4)
            
            DisclosureGroup("Net Balances") {
                if netBalances.isEmpty && !trip.participants.isEmpty {
                     Text("No expenses yet to calculate balances.")
                        .foregroundColor(.gray).padding(.vertical, 5)
                } else if trip.participants.isEmpty {
                    Text("Add participants to the trip to see balances.")
                        .foregroundColor(.gray).padding(.vertical, 5)
                }
                ForEach(netBalances, id: \.person.id) { item in
                    HStack {
                        Text(item.person.name)
                        Spacer()
                        Text(item.balance.formatted(.currency(code: "AUD")))
                            .foregroundColor(item.balance > 0.009 ? .green : (item.balance < -0.009 ? .red : .primary))
                            .fontWeight(abs(item.balance) > 0.009 ? .medium : .regular)
                    }
                    .font(.subheadline)
                    .padding(.vertical, 2)
                }
            }
            
            DisclosureGroup("Settlement Suggestions") {
                 let suggestions = settlementSuggestions
                 if suggestions.isEmpty && trip.expenses.isEmpty {
                     Text("No expenses to settle.").foregroundColor(.gray).padding(.vertical, 5)
                 } else if suggestions.isEmpty {
                     Text("Review balances!").foregroundColor(.gray).padding(.vertical, 5)
                 }
                 ForEach(suggestions, id: \.self) { suggestion in
                    Text(suggestion)
                        .font(.subheadline)
                        .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}
