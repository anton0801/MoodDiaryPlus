import SwiftUI
import SwiftData

@main
struct MoodDiaryApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
    
}

struct RootView: View {
    
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
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
            } else if requiresAuthentication && !isUnlocked {
                AuthenticationView(isUnlocked: $isUnlocked)
            } else {
                ContentView()
            }
        }
        .modelContainer(sharedModelContainer)
        .preferredColorScheme(.dark)
    }
}

struct ContentView: View {
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    @State private var selectedTab = 0
    @State private var tabBarOffset: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                TodayView()
                    .tag(0)
                
                CalendarView()
                    .tag(1)
                
                InsightsView_Enhanced()
                    .tag(2)
                
                HabitsView()
                    .tag(3)
                
                SettingsView()
                    .tag(4)
            }
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab, themeColor: themeColor)
                .offset(y: tabBarOffset)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let themeColor: String
    
    let tabs: [(icon: String, title: String)] = [
        ("house.fill", "Today"),
        ("calendar", "Calendar"),
        ("chart.bar.fill", "Insights"),
        ("list.bullet.clipboard.fill", "Habits"),
        ("gearshape.fill", "Settings")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 6) {
                        ZStack {
                            if selectedTab == index {
                                Circle()
                                    .fill(Color(hex: themeColor).opacity(0.2))
                                    .frame(width: 50, height: 50)
                            }
                            
                            Image(systemName: tab.icon)
                                .font(.system(size: 22, weight: selectedTab == index ? .semibold : .regular))
                                .foregroundColor(selectedTab == index ? Color(hex: themeColor) : .white.opacity(0.5))
                        }
                        
                        Text(tab.title)
                            .font(.system(size: 10, weight: selectedTab == index ? .semibold : .regular, design: .rounded))
                            .foregroundColor(selectedTab == index ? Color(hex: themeColor) : .white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            ZStack {
                Color.white.opacity(0.3)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: themeColor).opacity(0.1),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: -5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 10)
    }
}



#Preview {
    ContentView()
        .modelContainer(for: [MoodEntry.self, Habit.self], inMemory: true)
}
