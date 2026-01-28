import SwiftUI
import SwiftData

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedEntry: MoodEntry?
    @Published var showEntryDetail: Bool = false
    @Published var currentMonth: Date = Date()
    
    func fetchEntries(for date: Date, modelContext: ModelContext) -> [MoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
    }
    
    func fetchAllEntries(modelContext: ModelContext) -> [MoodEntry] {
        let descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching all entries: \(error)")
            return []
        }
    }
}
