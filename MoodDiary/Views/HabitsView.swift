import SwiftUI
import SwiftData

struct HabitsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = HabitsViewModel()
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    @AppStorage("isPremium") private var isPremium = false
    @Query private var habits: [Habit]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: themeColor).opacity(0.2),
                        Color(hex: "1a1a2e").opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Today's habits
                        todaySection
                        
                        // All habits
                        allHabitsSection
                        
                        // Add habit button
                        addHabitButton
                    }
                    .padding()
                }
            }
            .navigationTitle("Habits")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showAddHabit) {
                AddHabitView()
            }
            .onAppear {
                if habits.isEmpty {
                    viewModel.createDefaultHabits(modelContext: modelContext)
                }
            }
        }
    }
    
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Today's Progress")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(habits.filter { $0.isActive }) { habit in
                    TodayHabitRow(
                        habit: habit,
                        isCompleted: viewModel.isHabitCompletedToday(habit: habit)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.toggleHabitCompletion(habit: habit)
                        }
                    }
                }
            }
        }
    }
    
    private var allHabitsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("All Habits")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(habits) { habit in
                    HabitCard(habit: habit, viewModel: viewModel)
                }
            }
        }
    }
    
    private var addHabitButton: some View {
        Button(action: {
            if habits.count >= 5 && !isPremium {
                // Show premium upgrade prompt
            } else {
                viewModel.showAddHabit = true
            }
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                
                Text(habits.count >= 5 && !isPremium ? "Upgrade to Premium" : "Add New Habit")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(hex: themeColor), Color(hex: themeColor).opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(hex: themeColor).opacity(0.4), radius: 15, y: 5)
        }
    }
}

struct TodayHabitRow: View {
    let habit: Habit
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: habit.icon)
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: habit.color))
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color(hex: habit.color).opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("🔥 \(habit.currentStreak) day streak")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color(hex: habit.color).opacity(0.3), lineWidth: 3)
                        .frame(width: 32, height: 32)
                    
                    if isCompleted {
                        Circle()
                            .fill(Color(hex: habit.color))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct HabitCard: View {
    let habit: Habit
    @ObservedObject var viewModel: HabitsViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: habit.icon)
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: habit.color))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Created \(habit.createdDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack(spacing: 20) {
                StatBox(
                    title: "Current",
                    value: "\(habit.currentStreak)",
                    icon: "flame.fill",
                    color: Color(hex: habit.color)
                )
                
                StatBox(
                    title: "Best",
                    value: "\(habit.bestStreak)",
                    icon: "star.fill",
                    color: Color(hex: habit.color)
                )
                
                StatBox(
                    title: "Total",
                    value: "\(habit.completionDates.count)",
                    icon: "checkmark.circle.fill",
                    color: Color(hex: habit.color)
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: habit.color).opacity(0.3), lineWidth: 2)
                )
        )
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct AddHabitView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    
    @State private var habitName = ""
    @State private var selectedIcon = "star.fill"
    @State private var selectedColor = "#4ECDC4"
    
    let icons = ["star.fill", "heart.fill", "bolt.fill", "leaf.fill", "drop.fill", "flame.fill", "moon.fill", "sun.max.fill", "figure.run", "bed.double.fill", "book.fill", "cup.and.saucer.fill"]
    
    let colors = ["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7", "#DFE6E9", "#A29BFE", "#FD79A8"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1a1a2e")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Name input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Habit Name")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            TextField("e.g., Drink Water", text: $habitName)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.white)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                        
                        // Icon selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Icon")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                                ForEach(icons, id: \.self) { icon in
                                    Button(action: {
                                        selectedIcon = icon
                                    }) {
                                        Image(systemName: icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(selectedIcon == icon ? Color.white : Color(hex: selectedColor))
                                            .frame(width: 50, height: 50)
                                            .background(
                                                Circle()
                                                    .fill(selectedIcon == icon ? Color(hex: selectedColor) : Color.white.opacity(0.3))
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Color selector
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Choose Color")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                                ForEach(colors, id: \.self) { color in
                                    Button(action: {
                                        selectedColor = color
                                    }) {
                                        Circle()
                                            .fill(Color(hex: color))
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Save button
                        Button(action: saveHabit) {
                            Text("Create Habit")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color(hex: selectedColor), Color(hex: selectedColor).opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(habitName.isEmpty)
                        .opacity(habitName.isEmpty ? 0.5 : 1.0)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func saveHabit() {
        let habit = Habit(
            name: habitName,
            icon: selectedIcon,
            color: selectedColor
        )
        modelContext.insert(habit)
        dismiss()
    }
}
