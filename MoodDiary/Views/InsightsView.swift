import SwiftUI
import SwiftData
import Charts

struct InsightsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = InsightsViewModel()
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    @Query private var allEntries: [MoodEntry]
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
                        // Period selector
                        periodSelector
                        
                        // Average mood
                        averageMoodCard
                        
                        // Mood over time chart
                        moodLineChart
                        
                        // Mood distribution
                        moodPieChart
                        
                        // Word cloud
                        wordCloudSection
                        
                        // Habit impact
                        if !habits.isEmpty {
                            habitImpactSection
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.generateWordCloud(entries: filteredEntries)
            }
        }
    }
    
    private var filteredEntries: [MoodEntry] {
        let calendar = Calendar.current
        let now = Date()
        
        switch viewModel.selectedPeriod {
        case .week:
            return allEntries.filter { entry in
                calendar.dateComponents([.day], from: entry.date, to: now).day ?? 0 <= 7
            }
        case .month:
            return allEntries.filter { entry in
                calendar.dateComponents([.month], from: entry.date, to: now).month ?? 0 <= 1
            }
        case .year:
            return allEntries.filter { entry in
                calendar.dateComponents([.year], from: entry.date, to: now).year ?? 0 <= 1
            }
        }
    }
    
    private var periodSelector: some View {
        HStack(spacing: 12) {
            ForEach(InsightsViewModel.Period.allCases, id: \.self) { period in
                Button(action: {
                    withAnimation {
                        viewModel.selectedPeriod = period
                        viewModel.generateWordCloud(entries: filteredEntries)
                    }
                }) {
                    Text(period.rawValue)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(viewModel.selectedPeriod == period ? .white : .white.opacity(0.6))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(viewModel.selectedPeriod == period ? Color(hex: themeColor) : Color.white.opacity(0.3))
                        )
                }
            }
        }
    }
    
    private var averageMoodCard: some View {
        let avgMood = viewModel.calculateAverageMood(entries: filteredEntries)
        
        return VStack(spacing: 15) {
            Text("Average Mood")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                Text(moodEmoji(for: Int(avgMood)))
                    .font(.system(size: 60))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f", avgMood))
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("out of 10")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Text("\(filteredEntries.count) entries in this period")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var moodLineChart: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Mood Over Time")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if filteredEntries.isEmpty {
                emptyStateView(message: "No data to display")
            } else {
                Chart {
                    ForEach(filteredEntries.sorted(by: { $0.date < $1.date })) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Mood", entry.moodScore)
                        )
                        .foregroundStyle(Color(hex: themeColor))
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Date", entry.date),
                            y: .value("Mood", entry.moodScore)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: themeColor).opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 200)
                .chartYScale(domain: 1...10)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var moodPieChart: some View {
        let distribution = viewModel.getMoodDistribution(entries: filteredEntries)
        
        return VStack(alignment: .leading, spacing: 15) {
            Text("Mood Distribution")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if distribution.isEmpty {
                emptyStateView(message: "No data to display")
            } else {
                Chart(distribution) { item in
                    SectorMark(
                        angle: .value("Count", item.count),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(moodColor(for: item.mood))
                    .cornerRadius(5)
                }
                .frame(height: 250)
                
                // Legend
                FlowLayout(spacing: 12) {
                    ForEach(distribution) { item in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(moodColor(for: item.mood))
                                .frame(width: 12, height: 12)
                            
                            Text("\(moodEmoji(for: item.mood)) × \(item.count)")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var wordCloudSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Word Cloud")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if viewModel.wordCloudWords.isEmpty {
                emptyStateView(message: "Start writing notes to see your word cloud")
            } else {
                WordCloudView(words: viewModel.wordCloudWords, themeColor: themeColor)
                    .frame(height: 250)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    private var habitImpactSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Habit Impact on Mood")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(habits.filter { $0.isActive }) { habit in
                    let impact = viewModel.getHabitImpact(habit: habit, entries: filteredEntries)
                    
                    HStack {
                        Image(systemName: habit.icon)
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: habit.color))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color(hex: habit.color).opacity(0.2))
                            )
                        
                        Text(habit.name)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(impact > 0 ? "+\(String(format: "%.1f", impact))" : String(format: "%.1f", impact))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(impact > 0 ? .green : (impact < 0 ? .red : .white.opacity(0.5)))
                        
                        Image(systemName: impact > 0 ? "arrow.up" : (impact < 0 ? "arrow.down" : "minus"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(impact > 0 ? .green : (impact < 0 ? .red : .white.opacity(0.5)))
                    }
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.3))
            
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 150)
    }
    
    private func moodEmoji(for score: Int) -> String {
        switch score {
        case 1...2: return "😭"
        case 3...4: return "😟"
        case 5...6: return "😐"
        case 7...8: return "🙂"
        default: return "😍"
        }
    }
    
    private func moodColor(for score: Int) -> Color {
        let colors: [Color] = [
            Color(hex: "8B0000"), Color(hex: "CD5C5C"),
            Color(hex: "FF6B6B"), Color(hex: "FF8C42"),
            Color(hex: "FFB347"), Color(hex: "FFD700"),
            Color(hex: "77DD77"), Color(hex: "50C878"),
            Color(hex: "87CEEB"), Color(hex: "4169E1")
        ]
        return colors[min(max(score - 1, 0), 9)]
    }
}

struct WordCloudView: View {
    let words: [WordFrequency]
    let themeColor: String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(words.enumerated()), id: \.element.id) { index, word in
                    let size = fontSize(for: word.count, max: words.first?.count ?? 1)
                    let position = randomPosition(in: geometry.size, index: index)
                    
                    Text(word.word)
                        .font(.system(size: size, weight: .bold, design: .rounded))
                        .foregroundColor(randomColor(index: index))
                        .position(position)
                }
            }
        }
    }
    
    private func fontSize(for count: Int, max maxCount: Int) -> CGFloat {
        let normalized = Double(count) / Double(maxCount)
        return CGFloat(12 + (normalized * 32))
    }
    
    private func randomPosition(in size: CGSize, index: Int) -> CGPoint {
        let seed = index * 12345
        let x = CGFloat((seed * 7) % Int(size.width * 0.8)) + size.width * 0.1
        let y = CGFloat((seed * 13) % Int(size.height * 0.8)) + size.height * 0.1
        return CGPoint(x: x, y: y)
    }
    
    private func randomColor(index: Int) -> Color {
        let colors: [Color] = [
            Color(hex: themeColor),
            Color(hex: themeColor).opacity(0.8),
            Color(hex: themeColor).opacity(0.6),
            .white.opacity(0.9),
            .white.opacity(0.7)
        ]
        return colors[index % colors.count]
    }
}
