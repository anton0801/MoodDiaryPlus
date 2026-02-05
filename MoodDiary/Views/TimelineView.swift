import SwiftUI

struct TimelineView: View {
    let entries: [MoodEntry]
    @ObservedObject var viewModel: CalendarViewModel
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showFloatingDate = false
    
    var sortedEntries: [MoodEntry] {
        entries.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(sortedEntries.enumerated()), id: \.element.id) { index, entry in
                        TimelineEntryCard(
                            entry: entry,
                            isFirst: index == 0,
                            isLast: index == sortedEntries.count - 1,
                            showConnector: index < sortedEntries.count - 1
                        ) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                viewModel.selectedEntry = entry
                            }
                        }
                    }
                }
                .padding(.vertical, 20)
                .background(
                    GeometryReader { geometry in
                        Color.clear.preference(
                            key: TimelineScrollOffsetPreferenceKey.self,
                            value: geometry.frame(in: .named("scroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(TimelineScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
                showFloatingDate = value < -50
            }
            
            // Floating date indicator
            if showFloatingDate {
                FloatingDateIndicator(entries: sortedEntries, offset: scrollOffset)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

struct TimelineScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Timeline Entry Card
struct TimelineEntryCard: View {
    let entry: MoodEntry
    let isFirst: Bool
    let isLast: Bool
    let showConnector: Bool
    let action: () -> Void
    
    @State private var appeared = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Timeline connector
            VStack(spacing: 0) {
                // Top line
                if !isFirst {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: entry.colorTheme).opacity(0.3),
                                    Color(hex: entry.colorTheme)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 3)
                        .frame(height: 30)
                }
                
                // Mood indicator circle
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: entry.colorTheme).opacity(0.6),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 25
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    // Main circle
                    Circle()
                        .fill(Color(hex: entry.colorTheme))
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                    
                    // Emoji
                    Text(entry.moodEmoji)
                        .font(.system(size: 16))
                }
                .scaleEffect(appeared ? 1.0 : 0.5)
                .opacity(appeared ? 1.0 : 0)
                
                // Bottom line
                if showConnector {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: entry.colorTheme),
                                    Color(hex: entry.colorTheme).opacity(0.3)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 3)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 60)
            .padding(.leading, 20)
            
            // Entry content
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                action()
            }) {
                VStack(alignment: .leading, spacing: 15) {
                    // Date and time
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(entry.date.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        // Mood score badge
                        Text("\(entry.moodScore)/10")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(hex: entry.colorTheme).opacity(0.3))
                            )
                    }
                    
                    // Photo
                    if let photoData = entry.photoData,
                       let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(hex: entry.colorTheme), lineWidth: 2)
                            )
                    }
                    
                    // Note preview
                    if !entry.note.isEmpty {
                        Text(entry.note)
                            .font(.system(size: 14, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(3)
                    }
                    
                    // Activities
                    if !entry.selectedActivities.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(entry.selectedActivities.prefix(5), id: \.self) { activity in
                                    Text(activity)
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            Capsule()
                                                .fill(Color(hex: entry.colorTheme).opacity(0.3))
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: entry.colorTheme).opacity(0.5),
                                            Color(hex: entry.colorTheme).opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                )
                .shadow(color: Color(hex: entry.colorTheme).opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .buttonStyle(TimelineCardButtonStyle())
            .padding(.trailing, 20)
            .padding(.vertical, 10)
            .offset(x: appeared ? 0 : 50)
            .opacity(appeared ? 1.0 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
        }
    }
}

struct TimelineCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Floating Date Indicator
struct FloatingDateIndicator: View {
    let entries: [MoodEntry]
    let offset: CGFloat
    
    var currentDate: String {
        // Calculate which entry is currently visible based on offset
        guard let firstEntry = entries.first else { return "" }
        return firstEntry.date.formatted(date: .abbreviated, time: .omitted)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "calendar")
                .font(.system(size: 14))
            
            Text(currentDate)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.top, 10)
    }
}

// MARK: - Year Heatmap View
struct YearHeatmapView: View {
    let entries: [MoodEntry]
    
    @State private var selectedMonth: Date?
    @State private var showMonthDetail = false
    @State private var animateHeatmap = false
    
    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Year selector
                YearSelectorView(currentYear: currentYear)
                
                // Heatmap grid
                VStack(alignment: .leading, spacing: 20) {
                    Text("Activity Heatmap")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // Legend
                    HeatmapLegend()
                        .padding(.horizontal)
                    
                    // Monthly grid
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3),
                        spacing: 12
                    ) {
                        ForEach(1...12, id: \.self) { month in
                            MonthHeatmapCell(
                                month: month,
                                year: currentYear,
                                entries: entriesForMonth(month: month),
                                animate: animateHeatmap
                            ) {
                                selectedMonth = monthDate(month: month)
                                showMonthDetail = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 20)
                
                // Year statistics
                YearStatsView(entries: entries)
            }
            .padding(.vertical, 20)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animateHeatmap = true
            }
        }
        .sheet(isPresented: $showMonthDetail) {
            if let month = selectedMonth {
                MonthDetailView(month: month, entries: entriesForMonth(
                    month: Calendar.current.component(.month, from: month)
                ))
            }
        }
    }
    
    private func entriesForMonth(month: Int) -> [MoodEntry] {
        entries.filter { entry in
            let entryMonth = Calendar.current.component(.month, from: entry.date)
            let entryYear = Calendar.current.component(.year, from: entry.date)
            return entryMonth == month && entryYear == currentYear
        }
    }
    
    private func monthDate(month: Int) -> Date {
        var components = DateComponents()
        components.year = currentYear
        components.month = month
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - Year Selector
struct YearSelectorView: View {
    let currentYear: Int
    
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text("Year in Review")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(currentYear)")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .disabled(true)
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
}

// MARK: - Heatmap Legend
struct HeatmapLegend: View {
    var body: some View {
        HStack(spacing: 15) {
            Text("Less")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
            
            HStack(spacing: 5) {
                ForEach(0..<5) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(intensityColor(intensity: Double(index) / 4))
                        .frame(width: 20, height: 20)
                }
            }
            
            Text("More")
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
    
    private func intensityColor(intensity: Double) -> Color {
        Color(hex: "#4ECDC4").opacity(0.2 + (intensity * 0.8))
    }
}

// MARK: - Month Heatmap Cell
struct MonthHeatmapCell: View {
    let month: Int
    let year: Int
    let entries: [MoodEntry]
    let animate: Bool
    let action: () -> Void
    
    @State private var shimmer = false
    
    var monthName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        var components = DateComponents()
        components.month = month
        return dateFormatter.string(from: Calendar.current.date(from: components) ?? Date())
    }
    
    var intensity: Double {
        let daysInMonth = Calendar.current.range(of: .day, in: .month, for: monthDate)?.count ?? 30
        return Double(entries.count) / Double(daysInMonth)
    }
    
    var monthDate: Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }
    
    var averageMood: Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + $1.moodScore }
        return Double(sum) / Double(entries.count)
    }
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            VStack(spacing: 12) {
                // Month name
                Text(monthName)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                // Heatmap visualization
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    intensityColor.opacity(0.8),
                                    intensityColor.opacity(0.4)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Shimmer effect
                    if shimmer {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.3),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .offset(x: shimmer ? 100 : -100)
                    }
                    
                    // Entry count
                    VStack(spacing: 4) {
                        Text("\(entries.count)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("entries")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(height: 100)
                
                // Average mood indicator
                if !entries.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "face.smiling")
                            .font(.system(size: 12))
                        
                        Text(String(format: "%.1f", averageMood))
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(intensityColor.opacity(0.5), lineWidth: 2)
                    )
            )
            .shadow(color: intensityColor.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .scaleEffect(animate ? 1.0 : 0.8)
        .opacity(animate ? 1.0 : 0)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.7)
            .delay(Double(month) * 0.05),
            value: animate
        )
        .onAppear {
            if entries.count > 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(month) * 0.1) {
                    withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                        shimmer = true
                    }
                }
            }
        }
    }
    
    private var intensityColor: Color {
        if entries.isEmpty {
            return Color.white.opacity(0.1)
        }
        
        let moodColor: Color
        let score = Int(averageMood)
        let colors: [Color] = [
            Color(hex: "8B0000"), Color(hex: "CD5C5C"),
            Color(hex: "FF6B6B"), Color(hex: "FF8C42"),
            Color(hex: "FFB347"), Color(hex: "FFD700"),
            Color(hex: "77DD77"), Color(hex: "50C878"),
            Color(hex: "87CEEB"), Color(hex: "4169E1")
        ]
        moodColor = colors[min(max(score - 1, 0), 9)]
        
        return moodColor.opacity(0.5 + (intensity * 0.5))
    }
}

// MARK: - Year Stats View
struct YearStatsView: View {
    let entries: [MoodEntry]
    
    var totalEntries: Int { entries.count }
    var averageYearMood: Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + $1.moodScore }
        return Double(sum) / Double(entries.count)
    }
    
    var bestMonth: String {
        let monthGroups = Dictionary(grouping: entries) { entry in
            Calendar.current.component(.month, from: entry.date)
        }
        
        let monthAverages = monthGroups.mapValues { entries in
            Double(entries.reduce(0) { $0 + $1.moodScore }) / Double(entries.count)
        }
        
        guard let bestMonthNumber = monthAverages.max(by: { $0.value < $1.value })?.key else {
            return "—"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        var components = DateComponents()
        components.month = bestMonthNumber
        return dateFormatter.string(from: Calendar.current.date(from: components) ?? Date())
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Year in Numbers")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            HStack(spacing: 15) {
                YearStatCard(
                    icon: "calendar.badge.clock",
                    value: "\(totalEntries)",
                    label: "Total Entries",
                    gradient: [Color(hex: "#FF6B6B"), Color(hex: "#FF8787")]
                )
                
                YearStatCard(
                    icon: "face.smiling",
                    value: String(format: "%.1f", averageYearMood),
                    label: "Avg Mood",
                    gradient: [Color(hex: "#4ECDC4"), Color(hex: "#45B7D1")]
                )
                
                YearStatCard(
                    icon: "star.fill",
                    value: bestMonth,
                    label: "Best Month",
                    gradient: [Color(hex: "#FFD700"), Color(hex: "#FFA500")]
                )
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
}

struct YearStatCard: View {
    let icon: String
    let value: String
    let label: String
    let gradient: [Color]
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundStyle(
                    LinearGradient(
                        colors: gradient,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(animate ? 1.1 : 1.0)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            gradient[0].opacity(0.2),
                            gradient[1].opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Month Detail View
struct MonthDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let month: Date
    let entries: [MoodEntry]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "0F2027"),
                        Color(hex: "203A43"),
                        Color(hex: "2C5364")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Month header
                        VStack(spacing: 10) {
                            Text(month.formatted(.dateTime.month(.wide)))
                                .font(.system(size: 36, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("\(entries.count) entries")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 20)
                        
                        // Mini calendar
                        MonthMiniCalendar(month: month, entries: entries)
                        
                        // Entries list
                        VStack(alignment: .leading, spacing: 15) {
                            Text("All Entries")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(entries.sorted { $0.date > $1.date }) { entry in
                                CompactEntryCard(entry: entry)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

struct MonthMiniCalendar: View {
    let month: Date
    let entries: [MoodEntry]
    
    var body: some View {
        VStack(spacing: 12) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Days grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 7), spacing: 6) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        MiniDayCell(date: date, entry: getEntry(for: date))
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: month)!
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let daysInMonth = calendar.range(of: .day, in: .month, for: month)!.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(bySetting: .day, value: day, of: month) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func getEntry(for date: Date) -> MoodEntry? {
        entries.first { entry in
            Calendar.current.isDate(entry.date, inSameDayAs: date)
        }
    }
}

struct MiniDayCell: View {
    let date: Date
    let entry: MoodEntry?
    
    var body: some View {
        ZStack {
            if let entry = entry {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: entry.colorTheme).opacity(0.4))
                
                Text(entry.moodEmoji)
                    .font(.system(size: 18))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .frame(height: 40)
    }
}

struct CompactEntryCard: View {
    let entry: MoodEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Date
            VStack(spacing: 2) {
                Text(entry.date.formatted(.dateTime.day()))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(entry.date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(width: 50)
            
            // Emoji
            Text(entry.moodEmoji)
                .font(.system(size: 36))
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Mood score
            Text("\(entry.moodScore)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(hex: entry.colorTheme).opacity(0.3))
                )
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Enhanced Entry Detail View
struct EnhancedEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: MoodEntry
    
    @State private var showDeleteAlert = false
    @State private var imageScale: CGFloat = 1.0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic background based on mood
                LinearGradient(
                    colors: [
                        Color(hex: entry.colorTheme).opacity(0.4),
                        Color(hex: "0F2027"),
                        Color(hex: "203A43")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Hero image with parallax
                        if let photoData = entry.photoData,
                           let uiImage = UIImage(data: photoData) {
                            GeometryReader { geometry in
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width, height: 450)
                                    .clipShape(RoundedRectangle(cornerRadius: 0))
                                    .overlay(
                                        // Gradient overlay
                                        LinearGradient(
                                            colors: [
                                                .clear,
                                                .clear,
                                                Color(hex: entry.colorTheme).opacity(0.6)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .offset(y: -geometry.frame(in: .global).minY * 0.5)
                                    .scaleEffect(imageScale)
                                    .gesture(
                                        MagnificationGesture()
                                            .onChanged { value in
                                                imageScale = value
                                            }
                                            .onEnded { _ in
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    imageScale = 1.0
                                                }
                                            }
                                    )
                            }
                            .frame(height: 450)
                        }
                        
                        VStack(spacing: 25) {
                            // Mood header card
                            MoodHeaderCard(entry: entry)
                            
                            // Note card
                            if !entry.note.isEmpty {
                                NoteCard(note: entry.note, color: entry.colorTheme)
                            }
                            
                            // Activities card
                            if !entry.selectedActivities.isEmpty {
                                ActivitiesCard(activities: entry.selectedActivities, color: entry.colorTheme)
                            }
                            
                            // Action buttons
                            ActionButtonsCard(entry: entry, showDeleteAlert: $showDeleteAlert)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5)
                    }
                }
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { showShareSheet = true }) {
//                        Image(systemName: "square.and.arrow.up.circle.fill")
//                            .font(.system(size: 28))
//                            .foregroundColor(.white)
//                            .shadow(color: .black.opacity(0.3), radius: 5)
//                    }
//                }
            }
//            .sheet(isPresented: $showShareSheet) {
//                if let pdfURL = ExportManager.shared.exportEntryToPDF(entry: entry) {
//                    ShareSheet(items: [pdfURL])
//                }
//            }
            .alert("Delete Entry", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    // Delete logic here
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this entry? This action cannot be undone.")
            }
        }
    }
}

// Продолжить с карточками деталей и Insights View?
