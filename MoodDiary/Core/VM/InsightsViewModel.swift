import SwiftUI
import SwiftData

@MainActor
class InsightsViewModel: ObservableObject {
    @Published var selectedPeriod: Period = .week
    @Published var wordCloudWords: [WordFrequency] = []
    
    enum Period: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    func calculateAverageMood(entries: [MoodEntry]) -> Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + $1.moodScore }
        return Double(sum) / Double(entries.count)
    }
    
    func getMoodDistribution(entries: [MoodEntry]) -> [MoodDistribution] {
        var distribution: [Int: Int] = [:]
        
        for entry in entries {
            distribution[entry.moodScore, default: 0] += 1
        }
        
        return distribution.map { MoodDistribution(mood: $0.key, count: $0.value) }
            .sorted { $0.mood < $1.mood }
    }
    
    func generateWordCloud(entries: [MoodEntry]) {
        var wordCounts: [String: Int] = [:]
        let stopWords = Set(["the", "a", "an", "and", "or", "but", "in", "on", "at", "to", "for", "of", "with", "is", "was", "are", "been", "be", "have", "has", "had", "do", "does", "did", "will", "would", "could", "should", "may", "might", "i", "you", "he", "she", "it", "we", "they", "my", "your", "his", "her", "its", "our", "their"])
        
        for entry in entries {
            let words = entry.note.lowercased()
                .components(separatedBy: .whitespacesAndNewlines)
                .map { $0.trimmingCharacters(in: .punctuationCharacters) }
                .filter { $0.count > 2 && !stopWords.contains($0) }
            
            for word in words {
                wordCounts[word, default: 0] += 1
            }
        }
        
        wordCloudWords = wordCounts
            .map { WordFrequency(word: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(30)
            .map { $0 }
    }
    
    func getHabitImpact(habit: Habit, entries: [MoodEntry]) -> Double {
        let calendar = Calendar.current
        var withHabit: [Int] = []
        var withoutHabit: [Int] = []
        
        for entry in entries {
            let entryDay = calendar.startOfDay(for: entry.date)
            let habitCompleted = habit.completionDates.contains(where: { calendar.isDate($0, inSameDayAs: entryDay) })
            
            if habitCompleted {
                withHabit.append(entry.moodScore)
            } else {
                withoutHabit.append(entry.moodScore)
            }
        }
        
        guard !withHabit.isEmpty, !withoutHabit.isEmpty else { return 0 }
        
        let avgWith = Double(withHabit.reduce(0, +)) / Double(withHabit.count)
        let avgWithout = Double(withoutHabit.reduce(0, +)) / Double(withoutHabit.count)
        
        return avgWith - avgWithout
    }
}

struct MoodDistribution: Identifiable {
    let id = UUID()
    let mood: Int
    let count: Int
}

struct WordFrequency: Identifiable {
    let id = UUID()
    let word: String
    let count: Int
}
