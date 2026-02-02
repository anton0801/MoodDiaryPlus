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

struct FlowState: Equatable {
    var current: FlowPhase
    var endpoint: String?
    var isReady: Bool
    
    enum FlowPhase: Equatable {
        case initial
        case preparing
        case checking
        case verified
        case running(url: String)
        case waiting
        case disconnected
    }
    
    static var empty: FlowState {
        FlowState(current: .initial, endpoint: nil, isReady: false)
    }
}

// UNIQUE: Attribution Model
struct AttributionModel {
    let data: [String: Any]
    
    var isEmpty: Bool { data.isEmpty }
    var isOrganic: Bool { data["af_status"] as? String == "Organic" }
    
    static var empty: AttributionModel {
        AttributionModel(data: [:])
    }
}
