//
//  ICalendarGenerator.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 5/13/25.
//

import Foundation
import EventKit

class ICalendarGenerator {
    
    static func generateICalendar(for trip: Trip) -> String {
        var iCalString = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//iOSDevAssignment3//Trip Planner//EN
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        X-WR-CALNAME:\(trip.name) Itinerary
        X-WR-TIMEZONE:UTC
        """
        
        for activity in trip.activities {
            let eventString = createEvent(for: activity, in: trip)
            iCalString += "\n\(eventString)"
        }
        
        iCalString += "\nEND:VCALENDAR"
        
        return iCalString
    }
    
    private static func createEvent(for activity: Activity, in trip: Trip) -> String {
        // Use DateHelper to format dates in iCalendar format
        let startDateString = DateHelper.formatForICal(date: activity.startTime)
        let endDateString = DateHelper.formatForICal(date: activity.endTime)
        
        let uuid = UUID().uuidString
        
        var attendees = ""
        for participantId in activity.participants {
            if let participant = trip.participants.first(where: { $0.id == participantId }) {
                let email = participant.email.isEmpty ? "noemail@example.com" : participant.email
                attendees += "\nATTENDEE;CN=\(participant.name):mailto:\(email)"
            }
        }
        
        let description = activity.description // escape special characters
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: ";", with: "\\;")

        let event = """
        BEGIN:VEVENT
        UID:\(uuid)
        DTSTAMP:\(startDateString)
        DTSTART:\(startDateString)
        DTEND:\(endDateString)
        SUMMARY:\(activity.emoji) \(activity.title)
        DESCRIPTION:\(description)
        LOCATION:\(activity.location)\(attendees)
        END:VEVENT
        """
        
        return event
    }
    
    static func saveToTemporaryFile(content: String, fileName: String) -> URL? {
        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectoryURL.appendingPathComponent(fileName)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to save iCalendar file: \(error)")
            return nil
        }
    }
}
