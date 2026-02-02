import SwiftUI
import Charts

struct EnhancedMoodLineChart: View {
    let entries: [MoodEntry]
    let animate: Bool
    
    @State private var selectedPoint: MoodEntry?
    @State private var animationProgress: CGFloat = 0
    
    var sortedEntries: [MoodEntry] {
        entries.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Mood Trend")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let selected = selectedPoint {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(selected.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 12, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(selected.moodScore)/10")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                    )
                }
            }
            
            if sortedEntries.isEmpty {
                EmptyChartState(message: "No data to display")
            } else {
                ZStack {
                    // Grid lines
                    VStack(spacing: 0) {
                        ForEach(0..<6, id: \.self) { index in
                            HStack {
                                Text("\(10 - index * 2)")
                                    .font(.system(size: 10, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(width: 20)
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 1)
                            }
                            
                            if index < 5 {
                                Spacer()
                            }
                        }
                    }
                    .frame(height: 250)
                    .padding(.leading, 30)
                    
                    // Line chart
                    GeometryReader { geometry in
                        let chartWidth = geometry.size.width - 40
                        let chartHeight: CGFloat = 250
                        
                        // Gradient fill
                        Path { path in
                            guard let firstEntry = sortedEntries.first else { return }
                            
                            let startPoint = pointForEntry(
                                firstEntry,
                                index: 0,
                                width: chartWidth,
                                height: chartHeight
                            )
                            
                            path.move(to: CGPoint(x: startPoint.x + 30, y: startPoint.y))
                            
                            for (index, entry) in sortedEntries.enumerated() {
                                let point = pointForEntry(entry, index: index, width: chartWidth, height: chartHeight)
                                path.addLine(to: CGPoint(x: point.x + 30, y: point.y))
                            }
                            
                            // Complete the gradient path
                            if let lastEntry = sortedEntries.last {
                                let lastPoint = pointForEntry(
                                    lastEntry,
                                    index: sortedEntries.count - 1,
                                    width: chartWidth,
                                    height: chartHeight
                                )
                                path.addLine(to: CGPoint(x: lastPoint.x + 30, y: chartHeight))
                                path.addLine(to: CGPoint(x: 30, y: chartHeight))
                            }
                            
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#4ECDC4").opacity(0.3 * animationProgress),
                                    Color(hex: "#4ECDC4").opacity(0.05 * animationProgress)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        // Line
                        Path { path in
                            guard let firstEntry = sortedEntries.first else { return }
                            
                            let startPoint = pointForEntry(
                                firstEntry,
                                index: 0,
                                width: chartWidth,
                                height: chartHeight
                            )
                            
                            path.move(to: CGPoint(x: startPoint.x + 30, y: startPoint.y))
                            
                            for (index, entry) in sortedEntries.enumerated() {
                                let point = pointForEntry(entry, index: index, width: chartWidth, height: chartHeight)
                                path.addLine(to: CGPoint(x: point.x + 30, y: point.y))
                            }
                        }
                        .trim(from: 0, to: animationProgress)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "#4ECDC4"), Color(hex: "#45B7D1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                        )
                        .shadow(color: Color(hex: "#4ECDC4").opacity(0.5), radius: 10, x: 0, y: 5)
                        
                        // Data points
                        ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { index, entry in
                            let point = pointForEntry(entry, index: index, width: chartWidth, height: chartHeight)
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedPoint = selectedPoint?.id == entry.id ? nil : entry
                                }
                            }) {
                                ZStack {
                                    // Glow effect
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    moodColor(for: entry.moodScore).opacity(0.6),
                                                    .clear
                                                ],
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 20
                                            )
                                        )
                                        .frame(width: 40, height: 40)
                                    
                                    // Point
                                    Circle()
                                        .fill(moodColor(for: entry.moodScore))
                                        .frame(width: selectedPoint?.id == entry.id ? 16 : 10, height: selectedPoint?.id == entry.id ? 16 : 10)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                        )
                                        .shadow(color: moodColor(for: entry.moodScore).opacity(0.5), radius: 8)
                                    
                                    // Emoji on selected point
                                    if selectedPoint?.id == entry.id {
                                        Text(entry.moodEmoji)
                                            .font(.system(size: 24))
                                            .offset(y: -35)
                                    }
                                }
                            }
                            .position(x: point.x + 30, y: point.y)
                            .scaleEffect(animationProgress > CGFloat(index) / CGFloat(sortedEntries.count) ? 1.0 : 0.0)
                        }
                    }
                    .frame(height: 250)
                }
                .frame(height: 250)
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.3))
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func pointForEntry(_ entry: MoodEntry, index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        let x = (CGFloat(index) / CGFloat(max(sortedEntries.count - 1, 1))) * width
        let y = height - (CGFloat(entry.moodScore - 1) / 9.0) * height
        return CGPoint(x: x, y: y)
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

// MARK: - Mini Trend Chart
struct MiniTrendChart: View {
    let entries: [MoodEntry]
    let animate: Bool
    
    @State private var animationProgress: CGFloat = 0
    
    var sortedEntries: [MoodEntry] {
        entries.sorted { $0.date < $1.date }.suffix(7)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Last 7 Days")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if sortedEntries.isEmpty {
                Text("No recent entries")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { index, entry in
                        VStack(spacing: 8) {
                            // Bar
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            moodColor(for: entry.moodScore),
                                            moodColor(for: entry.moodScore).opacity(0.7)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: CGFloat(entry.moodScore) * 8 * animationProgress)
                                .shadow(color: moodColor(for: entry.moodScore).opacity(0.5), radius: 5)
                            
                            // Day label
                            Text(entry.date.formatted(.dateTime.weekday(.narrow)))
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 100)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.3))
        )
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                animationProgress = 1.0
            }
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

// MARK: - Quick Insights Card
struct QuickInsightsCard: View {
    let entries: [MoodEntry]
    
    var insights: [String] {
        var result: [String] = []
        
        if !entries.isEmpty {
            let avgMood = Double(entries.reduce(0) { $0 + $1.moodScore }) / Double(entries.count)
            
            if avgMood >= 7 {
                result.append("🌟 You're doing great! Your mood has been positive.")
            } else if avgMood <= 4 {
                result.append("💙 Remember to take care of yourself. Consider reaching out to someone.")
            }
            
            // Most frequent activity
            let allActivities = entries.flatMap { $0.selectedActivities }
            let activityCounts = Dictionary(grouping: allActivities, by: { $0 }).mapValues { $0.count }
            if let mostFrequent = activityCounts.max(by: { $0.value < $1.value }) {
                result.append("🎯 \(mostFrequent.key) appears most in your entries.")
            }
            
            // Consistency
            let calendar = Calendar.current
            let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.date) })
            if uniqueDays.count >= 7 {
                result.append("🔥 Amazing consistency! You've logged \(uniqueDays.count) different days.")
            }
        }
        
        return result.isEmpty ? ["Start logging to see insights!"] : result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color(hex: "#FFD700"))
                
                Text("Quick Insights")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(insights.enumerated()), id: \.offset) { index, insight in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#FFD700").opacity(0.3))
                            )
                        
                        Text(insight)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.3))
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Mood Velocity Card
struct MoodVelocityCard: View {
    let entries: [MoodEntry]
    
    var velocity: Double {
        guard entries.count >= 2 else { return 0 }
        let sorted = entries.sorted { $0.date < $1.date }
        
        var changes: [Double] = []
        for i in 1..<sorted.count {
            let change = Double(sorted[i].moodScore - sorted[i-1].moodScore)
            changes.append(change)
        }
        
        return changes.reduce(0, +) / Double(changes.count)
    }
    
    var velocityDescription: String {
        if velocity > 0.5 {
            return "Rapidly Improving"
        } else if velocity > 0.1 {
            return "Gradually Improving"
        } else if velocity < -0.5 {
            return "Declining"
        } else if velocity < -0.1 {
            return "Gradually Declining"
        } else {
            return "Stable"
        }
    }
    
    var velocityColor: Color {
        if velocity > 0.1 {
            return Color(hex: "#77DD77")
        } else if velocity < -0.1 {
            return Color(hex: "#FF6B6B")
        } else {
            return Color(hex: "#FFD700")
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Mood Velocity")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Rate of mood change")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: velocity > 0 ? "arrow.up.right" : velocity < 0 ? "arrow.down.right" : "arrow.right")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(velocityColor)
            }
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(format: "%.2f", abs(velocity)))
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(velocityColor)
                    
                    Text(velocityDescription)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Velocity gauge
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: min(abs(velocity) / 2, 1))
                        .stroke(velocityColor, lineWidth: 8)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Image(systemName: "gauge.high")
                        .font(.system(size: 24))
                        .foregroundColor(velocityColor)
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.3))
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Day of Week Analysis
struct DayOfWeekAnalysis: View {
    let entries: [MoodEntry]
    let animate: Bool
    
    @State private var animationProgress: CGFloat = 0
    
    var dayAverages: [(day: String, average: Double)] {
        let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let calendar = Calendar.current
        
        return weekdays.enumerated().map { index, day in
            let dayEntries = entries.filter { entry in
                calendar.component(.weekday, from: entry.date) == (index + 2) % 7 + 1
            }
            
            let average = dayEntries.isEmpty ? 0.0 : Double(dayEntries.reduce(0) { $0 + $1.moodScore }) / Double(dayEntries.count)
            return (day, average)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Day of Week Analysis")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                ForEach(dayAverages, id: \.day) { item in
                    HStack(spacing: 15) {
                        Text(item.day)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 40, alignment: .leading)
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                
                                // Progress
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                moodColor(for: Int(item.average)),
                                                moodColor(for: Int(item.average)).opacity(0.7)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * (item.average / 10) * animationProgress)
                            }
                        }
                        .frame(height: 30)
                        
                        Text(String(format: "%.1f", item.average))
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.3))
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                animationProgress = 1.0
            }
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

// MARK: - Time of Day Heatmap
struct TimeOfDayHeatmap: View {
    let entries: [MoodEntry]
    
    var timeData: [[Double]] {
        let calendar = Calendar.current
        var data: [[Double]] = Array(repeating: Array(repeating: 0, count: 24), count: 7)
        var counts: [[Int]] = Array(repeating: Array(repeating: 0, count: 24), count: 7)
        
        for entry in entries {
            let weekday = (calendar.component(.weekday, from: entry.date) + 5) % 7
            let hour = calendar.component(.hour, from: entry.date)
            
            data[weekday][hour] += Double(entry.moodScore)
            counts[weekday][hour] += 1
        }
        
        for weekday in 0..<7 {
            for hour in 0..<24 {
                if counts[weekday][hour] > 0 {
                    data[weekday][hour] /= Double(counts[weekday][hour])
                }
            }
        }
        
        return data
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Time of Day Patterns")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                // Hour labels
                HStack(spacing: 0) {
                    Text("")
                        .frame(width: 40)
                    
                    ForEach([0, 6, 12, 18], id: \.self) { hour in
                        Text("\(hour)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Heatmap grid
                VStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { day in
                        HStack(spacing: 4) {
                            Text(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][day])
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 40, alignment: .leading)
                            
                            ForEach(0..<24, id: \.self) { hour in
                                let value = timeData[day][hour]
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(heatmapColor(for: value))
                                    .frame(height: 20)
                            }
                        }
                    }
                }
            }
            
            // Legend
            HStack(spacing: 15) {
                Text("Less")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                
                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        RoundedRectangle(cornerRadius: 3)
                            .fill(heatmapColor(for: Double(index) * 2.5))
                            .frame(width: 15, height: 15)
                    }
                }
                
                Text("More")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.3))
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private func heatmapColor(for value: Double) -> Color {
        if value == 0 {
            return Color.white.opacity(0.1)
        }
        
        let intensity = value / 10
        return Color(hex: "#4ECDC4").opacity(0.2 + (intensity * 0.8))
    }
}

// MARK: - Enhanced 3D Word Cloud
struct Enhanced3DWordCloud: View {
    let words: [WordFrequency]
    let themeColor: String
    
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var dragStart: CGPoint = .zero
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Most Used Words")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if words.isEmpty {
                EmptyChartState(message: "Start writing notes to see your word cloud")
            } else {
                GeometryReader { geometry in
                    ZStack {
                        ForEach(Array(words.prefix(25).enumerated()), id: \.element.id) { index, word in
                            Text(word.word)
                                .font(.system(
                                    size: fontSize(for: word.count, max: words.first?.count ?? 1),
                                    weight: .bold,
                                    design: .rounded
                                ))
                                .foregroundColor(wordColor(index: index))
                                .position(wordPosition(index: index, in: geometry.size))
                                .rotation3DEffect(
                                    .degrees(rotationX),
                                    axis: (x: 1, y: 0, z: 0)
                                )
                                .rotation3DEffect(
                                    .degrees(rotationY),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                rotationY = dragStart.x + Double(value.translation.width) * 0.5
                                rotationX = dragStart.y - Double(value.translation.height) * 0.5
                            }
                            .onEnded { _ in
                                dragStart = CGPoint(x: rotationY, y: rotationX)
                            }
                    )
                }
                .frame(height: 300)
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.3))
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private func fontSize(for count: Int, max maxCount: Int) -> CGFloat {
        let normalized = Double(count) / Double(maxCount)
        return CGFloat(14 + (normalized * 28))
    }
    
    private func wordPosition(index: Int, in size: CGSize) -> CGPoint {
        // Distribute words in 3D space
        let angle = Double(index) * (2 * .pi / 25)
        let radius = size.width * 0.35
        
        let x = size.width / 2 + cos(angle) * radius
        let y = size.height / 2 + sin(angle) * radius * 0.6
        
        return CGPoint(x: x, y: y)
    }
    
    private func wordColor(index: Int) -> Color {
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

// MARK: - Habit Impact Chart
struct HabitImpactChart: View {
    let habits: [Habit]
    let entries: [MoodEntry]
    @ObservedObject var viewModel: InsightsViewModel
    let animate: Bool
    
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Habit Impact on Mood")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                ForEach(habits.filter { $0.isActive }) { habit in
                    let impact = viewModel.getHabitImpact(habit: habit, entries: entries)
                    
                    HStack(spacing: 15) {
                        Image(systemName: habit.icon)
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: habit.color))
                            .frame(width: 45, height: 45)
                            .background(
                                Circle()
                                    .fill(Color(hex: habit.color).opacity(0.2))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(habit.name)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.white.opacity(0.1))
                                    
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(impactColor(for: impact))
                                        .frame(width: geometry.size.width * abs(impact) / 3 * animationProgress)
                                }
                            }
                            .frame(height: 8)
                        }
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(impact > 0 ? "+\(String(format: "%.1f", impact))" : String(format: "%.1f", impact))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(impactColor(for: impact))
                            
                            Image(systemName: impact > 0 ? "arrow.up" : impact < 0 ? "arrow.down" : "minus")
                                .font(.system(size: 12))
                                .foregroundColor(impactColor(for: impact))
                        }
                        .frame(width: 50)
                    }
                    .padding(15)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.3))
                    )
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.3))
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                animationProgress = 1.0
            }
        }
    }
    
    private func impactColor(for impact: Double) -> Color {
        if impact > 0.5 {
            return Color(hex: "#77DD77")
        } else if impact < -0.5 {
            return Color(hex: "#FF6B6B")
        } else {
            return Color(hex: "#FFD700")
        }
    }
}

// MARK: - Activity Correlation Card
struct ActivityCorrelationCard: View {
    let entries: [MoodEntry]
    
    var correlations: [(activity: String, avgMood: Double, count: Int)] {
        let allActivities = entries.flatMap { entry in
            entry.selectedActivities.map { ($0, entry.moodScore) }
        }
        
        let grouped = Dictionary(grouping: allActivities, by: { $0.0 })
        
        return grouped.map { activity, values in
            let avgMood = Double(values.reduce(0) { $0 + $1.1 }) / Double(values.count)
            return (activity, avgMood, values.count)
        }
        .sorted { $0.avgMood > $1.avgMood }
        .prefix(5)
        .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "link")
                    .foregroundColor(Color(hex: "#4ECDC4"))
                
                Text("Activity Correlations")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            if correlations.isEmpty {
                Text("Track activities to see correlations")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(correlations, id: \.activity) { item in
                        HStack(spacing: 15) {
                            Text(item.activity)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            HStack(spacing: 8) {
                                Text(String(format: "%.1f", item.avgMood))
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(moodColor(for: Int(item.avgMood)))
                                
                                Text("(\(item.count)×)")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.3))
                        )
                    }
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.3))
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
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

// MARK: - Weather Impact Card (Mock)
struct WeatherImpactCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "cloud.sun.fill")
                    .foregroundColor(Color(hex: "#FFD700"))
                
                Text("Weather Impact")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Coming Soon")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#4ECDC4").opacity(0.3))
                    )
            }
            
            VStack(spacing: 15) {
                WeatherMockRow(
                    icon: "sun.max.fill",
                    weather: "Sunny",
                    avgMood: 7.8,
                    color: "#FFD700"
                )
                
                WeatherMockRow(
                    icon: "cloud.fill",
                    weather: "Cloudy",
                    avgMood: 6.2,
                    color: "#95A5A6"
                )
                
                WeatherMockRow(
                    icon: "cloud.rain.fill",
                    weather: "Rainy",
                    avgMood: 5.5,
                    color: "#4ECDC4"
                )
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.white.opacity(0.3))
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .opacity(0.6)
    }
}

struct WeatherMockRow: View {
    let icon: String
    let weather: String
    let avgMood: Double
    let color: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: color))
                .frame(width: 40)
            
            Text(weather)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(String(format: "%.1f", avgMood))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.3))
        )
    }
}
