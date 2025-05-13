//
//  Emoji.swift
//  iOSDevAssignment3
//
//  Created by Amy Zhou on 13/5/2025.
//

import Foundation
import UIKit

struct EmojiItem: Codable, Equatable, Identifiable {
    let emoji: String
    let description: String
    let aliases: [String]
    let tags: [String]
    
    var id: String { emoji }
}

func loadEmojiData() -> [EmojiItem] {

    if let url = Bundle.main.url(forResource: "emoji", withExtension: "json") {
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([EmojiItem].self, from: data)
            print("Decoded emoji.json with \(decoded.count) items")
            return decoded
        } catch {
            print("Error decoding emoji.json: \(error)")
        }
    } else {
        print("emoji.json not found")
    }

    print("fallback to default emojis")
    return fallbackEmojis()
}

func fallbackEmojis() -> [EmojiItem] {
    let fallback = [
        EmojiItem(emoji: "🏙️", description: "Cityscape", aliases: ["city", "urban", "skyline"], tags: ["city", "urban", "skyline"]),
        EmojiItem(emoji: "🏖️", description: "Beach with Umbrella", aliases: ["beach", "vacation", "summer"], tags: ["beach", "vacation", "summer"]),
        EmojiItem(emoji: "🏕️", description: "Camping", aliases: ["tent", "outdoors"], tags: ["nature", "wilderness", "hiking"]),
        EmojiItem(emoji: "🍽️", description: "Fork and Knife with Plate", aliases: ["dining", "restaurant", "food"], tags: ["dining", "restaurant", "food"]),
        EmojiItem(emoji: "🎪", description: "Circus Tent", aliases: ["circus", "entertainment", "show"], tags: ["circus", "entertainment", "show"])
    ]
    return fallback
}
