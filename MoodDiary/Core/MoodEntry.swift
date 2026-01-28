import Foundation
import SwiftData

@Model
final class MoodEntry {
    var id: UUID
    var date: Date
    var moodScore: Int // 1-10
    var moodEmoji: String
    var photoData: Data?
    var note: String
    var selectedActivities: [String]
    var colorTheme: String // Hex color
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        moodScore: Int,
        moodEmoji: String,
        photoData: Data? = nil,
        note: String = "",
        selectedActivities: [String] = [],
        colorTheme: String = ""
    ) {
        self.id = id
        self.date = date
        self.moodScore = moodScore
        self.moodEmoji = moodEmoji
        self.photoData = photoData
        self.note = note
        self.selectedActivities = selectedActivities
        self.colorTheme = colorTheme
    }
}
