//
//  iCalExporter.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 13/5/25.
//

import Foundation

struct iCalExporter {
    
    static func generateICSContent(for activity: Activity, participants: [Person]) -> String {
        let activityParticipants = participants.filter { person in
            activity.participants.contains(person.id)
        }
        
        let attendees = activityParticipants.map { person in
            "ATTENDEE;CN=\(person.name):mailto:\(person.email)"
        }.joined(separator: "\r\n")
        
        let uid = activity.id.uuidString
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        
        let startDate = dateFormatter.string(from: activity.startTime)
        let endDate = dateFormatter.string(from: activity.endTime)
        
        var description = activity.description
        if let notes = activity.notes, !notes.isEmpty {
            description += "\n\nNotes: \(notes)"
        }
        

        var icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//TripPlanner//iOSDevAssignment3//EN
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        BEGIN:VEVENT
        UID:\(uid)
        DTSTAMP:\(dateFormatter.string(from: Date()))
        DTSTART:\(startDate)
        DTEND:\(endDate)
        SUMMARY:\(activity.title)
        DESCRIPTION:\(description)
        LOCATION:\(activity.location)
        """
        
        if !attendees.isEmpty {
            icsContent += "\r\n\(attendees)"
        }
        
        icsContent += """
        
        END:VEVENT
        END:VCALENDAR
        """
        
        return icsContent
    }
    
    static func generateICSContent(for activities: [Activity], participants: [Person]) -> String {
        var icsContent = """
        BEGIN:VCALENDAR
        VERSION:2.0
        PRODID:-//TripPlanner//iOSDevAssignment3//EN
        CALSCALE:GREGORIAN
        METHOD:PUBLISH
        """
        
        for activity in activities {
            let activityParticipants = participants.filter { person in
                activity.participants.contains(person.id)
            }
            
            let attendees = activityParticipants.map { person in
                "ATTENDEE;CN=\(person.name):mailto:\(person.email)"
            }.joined(separator: "\r\n")
            
            let uid = activity.id.uuidString
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime]
            
            let startDate = dateFormatter.string(from: activity.startTime)
            let endDate = dateFormatter.string(from: activity.endTime)
            
            var description = activity.description
            if let notes = activity.notes, !notes.isEmpty {
                description += "\\n\\nNotes: \(notes)"
            }
            
            icsContent += """
            
            BEGIN:VEVENT
            UID:\(uid)
            DTSTAMP:\(dateFormatter.string(from: Date()))
            DTSTART:\(startDate)
            DTEND:\(endDate)
            SUMMARY:\(activity.title)
            DESCRIPTION:\(description)
            LOCATION:\(activity.location)
            """
            
            if !attendees.isEmpty {
                icsContent += "\r\n\(attendees)"
            }
            
            icsContent += "\r\nEND:VEVENT"
        }

        icsContent += """
        
        END:VCALENDAR
        """
        
        return icsContent
    }
    
    static func saveToTemporaryFile(content: String, filename: String = "activities.ics") -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(filename)
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving iCalendar file: \(error)")
            return nil
        }
    }
}