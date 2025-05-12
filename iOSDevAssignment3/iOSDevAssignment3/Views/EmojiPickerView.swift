import SwiftUI

struct EmojiPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedEmoji: String
    @State private var searchText = ""

    private let emojis = loadEmojiData()

    private var filteredEmojis: [EmojiItem] {
        if searchText.isEmpty {
            return emojis
        }
        return emojis.filter { emoji in
            emoji.description.localizedCaseInsensitiveContains(searchText) ||
            emoji.aliases.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
            emoji.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredEmojis, id: \.emoji) { emojiItem in
                    Button(action: {
                        selectedEmoji = emojiItem.emoji
                        dismiss()
                    }) {
                        HStack {
                            Text(emojiItem.emoji)
                                .font(.title)
                            VStack(alignment: .leading) {
                                Text(emojiItem.description)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(emojiItem.aliases.joined(separator: ", "))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search emojis...")
            .navigationTitle("Select Emoji")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
            }
        }
    }
}

#Preview {
    EmojiPickerView(selectedEmoji: .constant("🏙️"))
} 