import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CalendarViewModel()
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    @Query private var allEntries: [MoodEntry]
    
    @State private var showTimeline = false
    @State private var selectedViewMode: ViewMode = .calendar
    @State private var animateEntries = false
    
    enum ViewMode {
        case calendar
        case timeline
        case heatmap
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                AnimatedCalendarBackground(themeColor: themeColor)
                
                VStack(spacing: 0) {
                    // View mode selector
                    ViewModeSelectorView(selectedMode: $selectedViewMode)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    // Content based on selected mode
                    Group {
                        switch selectedViewMode {
                        case .calendar:
                            calendarView
                        case .timeline:
                            timelineView
                        case .heatmap:
                            heatmapView
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(Color(hex: themeColor))
                        Text("Journal")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { /* Export */ }) {
                            Label("Export Month", systemImage: "square.and.arrow.up")
                        }
                        Button(action: { /* Filter */ }) {
                            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        }
                        Button(action: { /* Search */ }) {
                            Label("Search", systemImage: "magnifyingglass")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(item: $viewModel.selectedEntry) { entry in
                EnhancedEntryDetailView(entry: entry)
            }
        }
    }
    
    private var calendarView: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Month navigator with 3D effect
                Enhanced3DMonthNavigator(viewModel: viewModel)
                
                // Calendar grid with animations
                EnhancedCalendarGrid(
                    viewModel: viewModel,
                    entries: filteredEntries,
                    animate: animateEntries
                )
                
                // Stats summary card
                MonthStatsCard(entries: filteredEntries, themeColor: themeColor)
                
                // Recent entries list
                RecentEntriesList(
                    entries: Array(filteredEntries.prefix(5)),
                    viewModel: viewModel
                )
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateEntries = true
            }
        }
    }
    
    private var timelineView: some View {
        TimelineView(entries: allEntries, viewModel: viewModel)
    }
    
    private var heatmapView: some View {
        YearHeatmapView(entries: allEntries)
    }
    
    private var filteredEntries: [MoodEntry] {
        allEntries.filter { entry in
            Calendar.current.isDate(entry.date, equalTo: viewModel.currentMonth, toGranularity: .month)
        }
    }
}

// MARK: - Animated Calendar Background
struct AnimatedCalendarBackground: View {
    let themeColor: String
    @State private var offset1: CGFloat = 0
    @State private var offset2: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(hex: themeColor).opacity(0.3),
                    Color(hex: "0F2027"),
                    Color(hex: "203A43")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating calendar icons
            GeometryReader { geometry in
                ForEach(0..<6, id: \.self) { index in
                    Image(systemName: "calendar")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.05))
                        .offset(
                            x: CGFloat(index % 2 == 0 ? offset1 : offset2),
                            y: CGFloat(index * 150)
                        )
                        .rotationEffect(.degrees(Double(index) * 30))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
                offset1 = UIScreen.main.bounds.width
                offset2 = -50
            }
        }
    }
}

// MARK: - View Mode Selector
struct ViewModeSelectorView: View {
    @Binding var selectedMode: CalendarView.ViewMode
    
    var body: some View {
        HStack(spacing: 0) {
            ModeButton(
                title: "Calendar",
                icon: "calendar",
                isSelected: selectedMode == .calendar
            ) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    selectedMode = .calendar
                }
            }
            
            ModeButton(
                title: "Timeline",
                icon: "clock.arrow.circlepath",
                isSelected: selectedMode == .timeline
            ) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    selectedMode = .timeline
                }
            }
            
            ModeButton(
                title: "Heatmap",
                icon: "square.grid.3x3.fill",
                isSelected: selectedMode == .heatmap
            ) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    selectedMode = .heatmap
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}

struct ModeButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.6))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "#4ECDC4") : Color.clear)
                    .shadow(
                        color: isSelected ? Color(hex: "#4ECDC4").opacity(0.5) : .clear,
                        radius: 10,
                        x: 0,
                        y: 5
                    )
            )
        }
    }
}

struct Enhanced3DMonthNavigator: View {
    @ObservedObject var viewModel: CalendarViewModel
    @State private var dragOffset: CGFloat = 0
    @State private var particles: [NavigatorParticle] = []
    
    var body: some View {
        ZStack {
            // Particles
            ForEach(particles) { particle in
                Circle()
                    .fill(Color(hex: "#4ECDC4"))
                    .frame(width: 4, height: 4)
                    .offset(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
            
            HStack(spacing: 20) {
                // Previous button
                NavigatorButton(icon: "chevron.left") {
                    generateParticles(direction: .left)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        viewModel.currentMonth = Calendar.current.date(
                            byAdding: .month,
                            value: -1,
                            to: viewModel.currentMonth
                        ) ?? viewModel.currentMonth
                    }
                }
                
                Spacer()
                
                // Month display with 3D effect
                VStack(spacing: 8) {
                    Text(viewModel.currentMonth.formatted(.dateTime.year()))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    
                    ZStack {
                        ForEach(0..<3, id: \.self) { layer in
                            Text(viewModel.currentMonth.formatted(.dateTime.month(.wide)))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(
                                    color: Color(hex: "#4ECDC4").opacity(0.5),
                                    radius: 10,
                                    x: 0,
                                    y: CGFloat(layer) * 2
                                )
                                // .offset(z: CGFloat(layer) * -5)
                                .opacity(1.0 - Double(layer) * 0.2)
                        }
                    }
                }
                .offset(x: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation.width * 0.5
                        }
                        .onEnded { value in
                            if abs(value.translation.width) > 100 {
                                let direction: NavigatorDirection = value.translation.width > 0 ? .left : .right
                                generateParticles(direction: direction)
                                
                                let monthOffset = value.translation.width > 0 ? -1 : 1
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    viewModel.currentMonth = Calendar.current.date(
                                        byAdding: .month,
                                        value: monthOffset,
                                        to: viewModel.currentMonth
                                    ) ?? viewModel.currentMonth
                                }
                            }
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                dragOffset = 0
                            }
                        }
                )
                
                Spacer()
                
                // Next button
                NavigatorButton(icon: "chevron.right") {
                    generateParticles(direction: .right)
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        viewModel.currentMonth = Calendar.current.date(
                            byAdding: .month,
                            value: 1,
                            to: viewModel.currentMonth
                        ) ?? viewModel.currentMonth
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#4ECDC4").opacity(0.5),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        }
    }
    
    enum NavigatorDirection {
        case left, right
    }
    
    private func generateParticles(direction: NavigatorDirection) {
        particles.removeAll()
        
        let startX: CGFloat = direction == .left ? UIScreen.main.bounds.width : 0
        
        for _ in 0..<15 {
            let particle = NavigatorParticle(
                id: UUID(),
                x: startX,
                y: CGFloat.random(in: -50...50),
                opacity: 1.0
            )
            particles.append(particle)
            
            withAnimation(.easeOut(duration: 0.8)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].x = direction == .left ? -100 : UIScreen.main.bounds.width + 100
                    particles[index].opacity = 0
                }
            }
        }
    }
}

struct NavigatorParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
}

struct NavigatorButton: View {
    let icon: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color(hex: "#4ECDC4").opacity(0.3))
                )
                .overlay(
                    Circle()
                        .stroke(Color(hex: "#4ECDC4"), lineWidth: 2)
                )
                .shadow(color: Color(hex: "#4ECDC4").opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Enhanced Calendar Grid
struct EnhancedCalendarGrid: View {
    @ObservedObject var viewModel: CalendarViewModel
    let entries: [MoodEntry]
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // Weekday headers with animation
            HStack(spacing: 0) {
                ForEach(Array(Calendar.current.shortWeekdaySymbols.enumerated()), id: \.offset) { index, day in
                    Text(day)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .offset(y: animate ? 0 : -20)
                        .opacity(animate ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                            .delay(Double(index) * 0.05),
                            value: animate
                        )
                }
            }
            
            // Days grid with staggered animation
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7),
                spacing: 8
            ) {
                ForEach(Array(daysInMonth().enumerated()), id: \.offset) { index, date in
                    if let date = date {
                        Enhanced3DDayCell(
                            date: date,
                            entry: getEntry(for: date),
                            isCurrentMonth: Calendar.current.isDate(
                                date,
                                equalTo: viewModel.currentMonth,
                                toGranularity: .month
                            ),
                            isToday: Calendar.current.isDateInToday(date)
                        ) {
                            if let entry = getEntry(for: date) {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    viewModel.selectedEntry = entry
                                }
                            }
                        }
                        .offset(y: animate ? 0 : 50)
                        .opacity(animate ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.7)
                            .delay(Double(index) * 0.02),
                            value: animate
                        )
                    } else {
                        Color.clear
                            .frame(height: 65)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private func daysInMonth() -> [Date?] {
        let calendar = Calendar.current
        let interval = calendar.dateInterval(of: .month, for: viewModel.currentMonth)!
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let daysInMonth = calendar.range(of: .day, in: .month, for: viewModel.currentMonth)!.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(bySetting: .day, value: day, of: viewModel.currentMonth) {
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

// MARK: - Enhanced 3D Day Cell
struct Enhanced3DDayCell: View {
    let date: Date
    let entry: MoodEntry?
    let isCurrentMonth: Bool
    let isToday: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    @State private var shimmerOffset: CGFloat = -100
    
    var body: some View {
        Button(action: {
            if entry != nil {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                action()
            }
        }) {
            ZStack {
                // Base layer
                RoundedRectangle(cornerRadius: 14)
                    .fill(backgroundColor)
                
                // Shimmer effect for entries
                if entry != nil {
                    RoundedRectangle(cornerRadius: 14)
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
                        .offset(x: shimmerOffset)
                        .mask(RoundedRectangle(cornerRadius: 14))
                }
                
                VStack(spacing: 4) {
                    Text("\(Calendar.current.component(.day, from: date))")
                        .font(.system(size: 16, weight: isToday ? .black : .semibold, design: .rounded))
                        .foregroundColor(textColor)
                    
                    if let entry = entry {
                        Text(entry.moodEmoji)
                            .font(.system(size: 20))
                            .shadow(color: Color(hex: entry.colorTheme).opacity(0.6), radius: 8)
                    } else {
                        Circle()
                            .fill(.clear)
                            .frame(width: 4, height: 4)
                    }
                }
                
                // Today indicator
                if isToday {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#FFD700"),
                                    Color(hex: "#FFA500")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                }
                
                // Entry indicator glow
                if let entry = entry {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: entry.colorTheme).opacity(0.6), lineWidth: 2)
                }
            }
            .frame(height: 65)
            .shadow(
                color: entry != nil ? Color(hex: entry!.colorTheme).opacity(0.3) : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
            .rotation3DEffect(
                .degrees(isPressed ? 5 : 0),
                axis: (x: 1, y: 0, z: 0)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .disabled(entry == nil)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if entry != nil {
                        isPressed = true
                    }
                }
                .onEnded { _ in isPressed = false }
        )
        .onAppear {
            if entry != nil {
                startShimmer()
            }
        }
    }
    
    private var backgroundColor: Color {
        if let entry = entry {
            return Color(hex: entry.colorTheme).opacity(0.3)
        } else if !isCurrentMonth {
            return Color.white.opacity(0.3)
        } else {
            return Color.white.opacity(0.5)
        }
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .white.opacity(0.3)
        } else if isToday {
            return Color(hex: "#FFD700")
        } else {
            return .white
        }
    }
    
    private func startShimmer() {
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false).delay(Double.random(in: 0...2))) {
            shimmerOffset = 200
        }
    }
}

// MARK: - Month Stats Card
struct MonthStatsCard: View {
    let entries: [MoodEntry]
    let themeColor: String
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("This Month")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                if !entries.isEmpty {
                    Text("\(entries.count) entries")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            if entries.isEmpty {
                VStack(spacing: 15) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("No entries this month")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Start journaling to see your stats")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                HStack(spacing: 15) {
                    StatBubble(
                        icon: "face.smiling",
                        value: String(format: "%.1f", averageMood),
                        label: "Avg Mood",
                        color: moodColor
                    )
                    
                    StatBubble(
                        icon: "arrow.up.right",
                        value: "\(bestMood)",
                        label: "Best Day",
                        color: "#77DD77"
                    )
                    
                    StatBubble(
                        icon: "chart.line.uptrend.xyaxis",
                        value: moodTrend,
                        label: "Trend",
                        color: themeColor
                    )
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private var averageMood: Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + $1.moodScore }
        return Double(sum) / Double(entries.count)
    }
    
    private var bestMood: Int {
        entries.map { $0.moodScore }.max() ?? 0
    }
    
    private var moodColor: String {
        let score = Int(averageMood)
        let colors = ["#8B0000", "#CD5C5C", "#FF6B6B", "#FF8C42", "#FFB347", "#FFD700", "#77DD77", "#50C878", "#87CEEB", "#4169E1"]
        return colors[min(max(score - 1, 0), 9)]
    }
    
    private var moodTrend: String {
        guard entries.count >= 2 else { return "—" }
        
        let sortedEntries = entries.sorted { $0.date < $1.date }
        let firstHalf = sortedEntries.prefix(sortedEntries.count / 2)
        let secondHalf = sortedEntries.suffix(sortedEntries.count / 2)
        
        let firstAvg = Double(firstHalf.reduce(0) { $0 + $1.moodScore }) / Double(firstHalf.count)
        let secondAvg = Double(secondHalf.reduce(0) { $0 + $1.moodScore }) / Double(secondHalf.count)
        
        let diff = secondAvg - firstAvg
        
        if diff > 0.5 {
            return "↗️"
        } else if diff < -0.5 {
            return "↘️"
        } else {
            return "→"
        }
    }
}

struct StatBubble: View {
    let icon: String
    let value: String
    let label: String
    let color: String
    
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: color).opacity(0.3),
                                Color(hex: color).opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 40
                        )
                    )
                    .frame(width: 70, height: 70)
                    .scaleEffect(animate ? 1.1 : 1.0)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(Color(hex: color))
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Recent Entries List
struct RecentEntriesList: View {
    let entries: [MoodEntry]
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recent Entries")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 5)
            
            if entries.isEmpty {
                Text("No entries yet")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 30)
            } else {
                VStack(spacing: 12) {
                    ForEach(entries) { entry in
                        EnhancedEntryRow(entry: entry) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                viewModel.selectedEntry = entry
                            }
                        }
                    }
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

struct EnhancedEntryRow: View {
    let entry: MoodEntry
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 15) {
                // Photo thumbnail with glow
                if let photoData = entry.photoData,
                   let uiImage = UIImage(data: photoData) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(hex: entry.colorTheme).opacity(0.6),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 75, height: 75)
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 65, height: 65)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: entry.colorTheme), lineWidth: 3)
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(entry.moodEmoji)
                            .font(.system(size: 28))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(entry.date.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 12, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    
                    if !entry.note.isEmpty {
                        Text(entry.note)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: entry.colorTheme).opacity(0.2),
                                Color(hex: entry.colorTheme).opacity(0.05)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color(hex: entry.colorTheme).opacity(0.3), lineWidth: 1)
            )
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
