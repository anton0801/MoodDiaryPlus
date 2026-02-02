import Foundation
import SwiftData

class DataManager {
    static let shared = DataManager()
    
    private init() {}
    
    // MARK: - Streak Calculation
    func calculateStreak(entries: [MoodEntry]) -> Int {
        guard !entries.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.date > $1.date }
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        // Check if there's an entry today
        let hasToday = sortedEntries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: Date())
        }
        
        if !hasToday {
            // If no entry today, start checking from yesterday
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }
        
        for entry in sortedEntries {
            let entryDate = calendar.startOfDay(for: entry.date)
            
            if calendar.isDate(entryDate, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if entryDate < currentDate {
                // Gap found, stop counting
                break
            }
        }
        
        return streak
    }
    
    // MARK: - Data Export
    func exportAllDataToJSON(modelContext: ModelContext) -> URL? {
        let descriptor = FetchDescriptor<MoodEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        
        do {
            let entries = try modelContext.fetch(descriptor)
            
            let exportData = entries.map { entry in
                return [
                    "id": entry.id.uuidString,
                    "date": ISO8601DateFormatter().string(from: entry.date),
                    "moodScore": entry.moodScore,
                    "moodEmoji": entry.moodEmoji,
                    "note": entry.note,
                    "activities": entry.selectedActivities,
                    "colorTheme": entry.colorTheme
                ] as [String : Any]
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("MoodDiary_Export_\(Date().timeIntervalSince1970).json")
            try jsonData.write(to: tempURL)
            
            return tempURL
        } catch {
            print("Error exporting data: \(error)")
            return nil
        }
    }
    
    // MARK: - Data Import
    func importDataFromJSON(url: URL, modelContext: ModelContext) -> Bool {
        do {
            let jsonData = try Data(contentsOf: url)
            guard let importData = try JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] else {
                return false
            }
            
            for entryDict in importData {
                guard let dateString = entryDict["date"] as? String,
                      let date = ISO8601DateFormatter().date(from: dateString),
                      let moodScore = entryDict["moodScore"] as? Int,
                      let moodEmoji = entryDict["moodEmoji"] as? String else {
                    continue
                }
                
                let entry = MoodEntry(
                    date: date,
                    moodScore: moodScore,
                    moodEmoji: moodEmoji,
                    note: entryDict["note"] as? String ?? "",
                    selectedActivities: entryDict["activities"] as? [String] ?? [],
                    colorTheme: entryDict["colorTheme"] as? String ?? "#4ECDC4"
                )
                
                modelContext.insert(entry)
            }
            
            try modelContext.save()
            return true
        } catch {
            print("Error importing data: \(error)")
            return false
        }
    }
    
    // MARK: - Clear All Data
    func clearAllData(modelContext: ModelContext) {
        let entryDescriptor = FetchDescriptor<MoodEntry>()
        let habitDescriptor = FetchDescriptor<Habit>()
        
        do {
            let entries = try modelContext.fetch(entryDescriptor)
            let habits = try modelContext.fetch(habitDescriptor)
            
            for entry in entries {
                modelContext.delete(entry)
            }
            
            for habit in habits {
                modelContext.delete(habit)
            }
            
            try modelContext.save()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
    
    // MARK: - Statistics
    func calculateAverageMood(entries: [MoodEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + $1.moodScore }
        return Double(sum) / Double(entries.count)
    }
    
    func getBestMood(entries: [MoodEntry]) -> Int {
        entries.map { $0.moodScore }.max() ?? 0
    }
    
    func getWorstMood(entries: [MoodEntry]) -> Int {
        entries.map { $0.moodScore }.min() ?? 0
    }
    
    func getMostProductiveDay(entries: [MoodEntry]) -> String? {
        guard !entries.isEmpty else { return nil }
        
        let calendar = Calendar.current
        let weekdayGroups = Dictionary(grouping: entries) { entry in
            calendar.component(.weekday, from: entry.date)
        }
        
        let weekdayAverages = weekdayGroups.mapValues { entries in
            Double(entries.reduce(0) { $0 + $1.moodScore }) / Double(entries.count)
        }
        
        guard let bestWeekday = weekdayAverages.max(by: { $0.value < $1.value })?.key else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        return dateFormatter.weekdaySymbols[bestWeekday - 1]
    }
}

// MARK: - Extension for MoodEntry
extension MoodEntry {
    func toJSON() -> [String: Any] {
        return [
            "id": id.uuidString,
            "date": ISO8601DateFormatter().string(from: date),
            "moodScore": moodScore,
            "moodEmoji": moodEmoji,
            "note": note,
            "activities": selectedActivities,
            "colorTheme": colorTheme
        ]
    }
}

// MARK: - Extension for Habit
extension Habit {
    func toJSON() -> [String: Any] {
        return [
            "id": id.uuidString,
            "name": name,
            "icon": icon,
            "color": color,
            "createdDate": ISO8601DateFormatter().string(from: createdDate),
            "currentStreak": currentStreak,
            "bestStreak": bestStreak,
            "completionDates": completionDates.map { ISO8601DateFormatter().string(from: $0) },
            "isActive": isActive
        ]
    }
}
