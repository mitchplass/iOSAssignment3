//
//  TripViewModel.swift
//  iOSDevAssignment3
//
//  Created by baileyt on 3/5/25.
//

import Foundation
import Combine

class TripViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var currentTrip: Trip?
    
    private let saveKey = "saved_trips"
    
    init() {
        loadTrips()
    }
    
    func addTrip(_ trip: Trip) {
        trips.append(trip)
        saveTrips()
    }
    
    func updateTrip(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
            
            if currentTrip?.id == trip.id {
                currentTrip = trip
            }
            
            saveTrips()
        }
    }
    
    func deleteTrip(id: UUID) {
        trips.removeAll { $0.id == id }
        
        if currentTrip?.id == id {
            currentTrip = nil
        }
        
        saveTrips()
    }
    
    func addActivity(to tripId: UUID, activity: Activity) {
        if let index = trips.firstIndex(where: { $0.id == tripId }) {
            trips[index].activities.append(activity)
            
            if currentTrip?.id == tripId {
                currentTrip?.activities.append(activity)
            }
            
            saveTrips()
        }
    }
    
    func updateActivity(in tripId: UUID, activity: Activity) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }),
           let activityIndex = trips[tripIndex].activities.firstIndex(where: { $0.id == activity.id }) {
            trips[tripIndex].activities[activityIndex] = activity
            
            if currentTrip?.id == tripId {
                if let currentActivityIndex = currentTrip?.activities.firstIndex(where: { $0.id == activity.id }) {
                    currentTrip?.activities[currentActivityIndex] = activity
                }
            }
            
            saveTrips()
        }
    }
    
    func deleteActivity(from tripId: UUID, activityId: UUID) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }) {
            trips[tripIndex].activities.removeAll { $0.id == activityId }
            
            if currentTrip?.id == tripId {
                currentTrip?.activities.removeAll { $0.id == activityId }
            }
            
            saveTrips()
        }
    }
    
    func addItem(to tripId: UUID, item: Item) {
        if let index = trips.firstIndex(where: { $0.id == tripId }) {
            trips[index].items.append(item)
            
            if currentTrip?.id == tripId {
                currentTrip?.items.append(item)
            }
            
            saveTrips()
        }
    }
    
    func updateItem(in tripId: UUID, item: Item) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }),
           let itemIndex = trips[tripIndex].items.firstIndex(where: { $0.id == item.id }) {
            trips[tripIndex].items[itemIndex] = item
            
            if currentTrip?.id == tripId {
                if let currentItemIndex = currentTrip?.items.firstIndex(where: { $0.id == item.id }) {
                    currentTrip?.items[currentItemIndex] = item
                }
            }
            
            saveTrips()
        }
    }
    
    func deleteItem(from tripId: UUID, itemId: UUID) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }) {
            trips[tripIndex].items.removeAll { $0.id == itemId }
            
            if currentTrip?.id == tripId {
                currentTrip?.items.removeAll { $0.id == itemId }
            }
            
            saveTrips()
        }
    }
    
    func addExpense(to tripId: UUID, expense: Expense) {
        if let index = trips.firstIndex(where: { $0.id == tripId }) {
            trips[index].expenses.append(expense)
            
            if currentTrip?.id == tripId {
                currentTrip?.expenses.append(expense)
            }
            
            saveTrips()
        }
    }
    
    func updateExpense(in tripId: UUID, expense: Expense) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }),
           let expenseIndex = trips[tripIndex].expenses.firstIndex(where: { $0.id == expense.id }) {
            trips[tripIndex].expenses[expenseIndex] = expense
            
            if currentTrip?.id == tripId {
                if let currentExpenseIndex = currentTrip?.expenses.firstIndex(where: { $0.id == expense.id }) {
                    currentTrip?.expenses[currentExpenseIndex] = expense
                }
            }
            
            saveTrips()
        }
    }
    
    func deleteExpense(from tripId: UUID, expenseId: UUID) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }) {
            trips[tripIndex].expenses.removeAll { $0.id == expenseId }
            
            if currentTrip?.id == tripId {
                currentTrip?.expenses.removeAll { $0.id == expenseId }
            }
            
            saveTrips()
        }
    }
    
    func addParticipant(to tripId: UUID, person: Person) {
        if let index = trips.firstIndex(where: { $0.id == tripId }) {
            trips[index].participants.append(person)
            
            if currentTrip?.id == tripId {
                currentTrip?.participants.append(person)
            }
            
            saveTrips()
        }
    }
    
    func updateParticipant(in tripId: UUID, person: Person) {
        if let tripIndex = trips.firstIndex(where: { $0.id == tripId }),
           let personIndex = trips[tripIndex].participants.firstIndex(where: { $0.id == person.id }) {
            trips[tripIndex].participants[personIndex] = person
            
            if currentTrip?.id == tripId {
                if let currentPersonIndex = currentTrip?.participants.firstIndex(where: { $0.id == person.id }) {
                    currentTrip?.participants[currentPersonIndex] = person
                }
            }
            
            saveTrips()
        }
    }
    
    func deleteParticipant(from tripId: UUID, personId: Person.ID) {
        guard let tripIndex = trips.firstIndex(where: { $0.id == tripId }) else { return }

        trips[tripIndex].participants.removeAll { $0.id == personId }

        for i in 0..<trips[tripIndex].activities.count {
            trips[tripIndex].activities[i].participants.removeAll { $0 == personId }
        }

        for i in 0..<trips[tripIndex].items.count {
            if trips[tripIndex].items[i].assignedTo == personId {
                trips[tripIndex].items[i].assignedTo = nil
            }
        }

        var expensesToKeep: [Expense] = []
        for var expense in trips[tripIndex].expenses {
            if expense.paidBy == personId {
                continue
            }
            
            expense.splitAmong.removeAll { $0 == personId }
            expense.customSplitAmounts?.removeValue(forKey: personId)
            
            if expense.splitAmong.isEmpty && (expense.customSplitAmounts == nil || expense.customSplitAmounts!.isEmpty) {
            }
            expensesToKeep.append(expense)
        }
        trips[tripIndex].expenses = expensesToKeep
        
        if currentTrip?.id == tripId {
            if let updatedTrip = trips.first(where: { $0.id == tripId }) {
                 currentTrip = updatedTrip
            } else {
                 currentTrip = nil
            }
        }
        
        saveTrips()
    }
    
    private func saveTrips() {
        if let encoded = try? JSONEncoder().encode(trips) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadTrips() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Trip].self, from: data) {
            trips = decoded
        }
    }
}
