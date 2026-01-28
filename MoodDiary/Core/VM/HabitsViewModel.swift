
import SwiftUI
import SwiftData

@MainActor
class HabitsViewModel: ObservableObject {
    @Published var showAddHabit: Bool = false
    @Published var selectedHabit: Habit?
    
    let defaultHabits = [
        ("Drink 2L Water", "drop.fill", "#3498DB"),
        ("30 min Workout", "figure.run", "#E74C3C"),
        ("7+ h Sleep", "bed.double.fill", "#9B59B6"),
        ("Meditate", "figure.mind.and.body", "#00BCD4"),
        ("Read 20 min", "book.fill", "#16A085")
    ]
    
    func createDefaultHabits(modelContext: ModelContext) {
        for (name, icon, color) in defaultHabits {
            let habit = Habit(name: name, icon: icon, color: color)
            modelContext.insert(habit)
        }
    }
    
    func toggleHabitCompletion(habit: Habit, date: Date = Date()) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: date)
        
        if let index = habit.completionDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: today) }) {
            habit.completionDates.remove(at: index)
        } else {
            habit.completionDates.append(today)
            habit.completionDates.sort(by: >)
        }
        
        updateStreaks(habit: habit)
    }
    
    func isHabitCompletedToday(habit: Habit) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return habit.completionDates.contains(where: { calendar.isDate($0, inSameDayAs: today) })
    }
    
    private func updateStreaks(habit: Habit) {
        let calendar = Calendar.current
        let sortedDates = habit.completionDates.sorted(by: >)
        
        var streak = 0
        var previousDate: Date?
        
        for date in sortedDates {
            if let prev = previousDate {
                let daysDiff = calendar.dateComponents([.day], from: date, to: prev).day ?? 0
                if daysDiff == 1 {
                    streak += 1
                } else {
                    break
                }
            } else {
                streak = 1
            }
            previousDate = date
        }
        
        habit.currentStreak = streak
        if streak > habit.bestStreak {
            habit.bestStreak = streak
        }
    }
}
