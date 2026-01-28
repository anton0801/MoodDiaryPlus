import SwiftUI
import SwiftData

@main
struct MoodDiaryApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("requiresAuthentication") private var requiresAuthentication = false
    @State private var isUnlocked = false
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MoodEntry.self,
            Habit.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingView()
                } else if requiresAuthentication && !isUnlocked {
                    AuthenticationView(isUnlocked: $isUnlocked)
                } else {
                    SplashScreenView()
                }
            }
            .modelContainer(sharedModelContainer)
        }
    }
}

import SwiftUI

struct ContentView: View {
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "calendar.badge.plus")
                }
            
            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
            
            HabitsView()
                .tabItem {
                    Label("Habits", systemImage: "list.bullet.clipboard")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color(hex: themeColor))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [MoodEntry.self, Habit.self], inMemory: true)
}
