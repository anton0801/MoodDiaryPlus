import SwiftUI
import SwiftData
import Charts
import WebKit
import Combine
//
//struct InsightsView: View {
//    @Environment(\.modelContext) private var modelContext
//    @StateObject private var viewModel = InsightsViewModel()
//    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
//    @Query private var allEntries: [MoodEntry]
//    @Query private var habits: [Habit]
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                LinearGradient(
//                    colors: [
//                        Color(hex: themeColor).opacity(0.2),
//                        Color(hex: "1a1a2e").opacity(0.95)
//                    ],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(spacing: 25) {
//                        // Period selector
//                        periodSelector
//                        
//                        // Average mood
//                        averageMoodCard
//                        
//                        // Mood over time chart
//                        moodLineChart
//                        
//                        // Mood distribution
//                        moodPieChart
//                        
//                        // Word cloud
//                        wordCloudSection
//                        
//                        // Habit impact
//                        if !habits.isEmpty {
//                            habitImpactSection
//                        }
//                    }
//                    .padding()
//                }
//            }
//            .navigationTitle("Insights")
//            .navigationBarTitleDisplayMode(.large)
//            .onAppear {
//                viewModel.generateWordCloud(entries: filteredEntries)
//            }
//        }
//    }
//    
//    private var filteredEntries: [MoodEntry] {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        switch viewModel.selectedPeriod {
//        case .week:
//            return allEntries.filter { entry in
//                calendar.dateComponents([.day], from: entry.date, to: now).day ?? 0 <= 7
//            }
//        case .month:
//            return allEntries.filter { entry in
//                calendar.dateComponents([.month], from: entry.date, to: now).month ?? 0 <= 1
//            }
//        case .year:
//            return allEntries.filter { entry in
//                calendar.dateComponents([.year], from: entry.date, to: now).year ?? 0 <= 1
//            }
//        }
//    }
//    
//    private var periodSelector: some View {
//        HStack(spacing: 12) {
//            ForEach(InsightsViewModel.Period.allCases, id: \.self) { period in
//                Button(action: {
//                    withAnimation {
//                        viewModel.selectedPeriod = period
//                        viewModel.generateWordCloud(entries: filteredEntries)
//                    }
//                }) {
//                    Text(period.rawValue)
//                        .font(.system(size: 14, weight: .semibold, design: .rounded))
//                        .foregroundColor(viewModel.selectedPeriod == period ? .white : .white.opacity(0.6))
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 10)
//                        .background(
//                            Capsule()
//                                .fill(viewModel.selectedPeriod == period ? Color(hex: themeColor) : Color.white.opacity(0.3))
//                        )
//                }
//            }
//        }
//    }
//    
//    private var averageMoodCard: some View {
//        let avgMood = viewModel.calculateAverageMood(entries: filteredEntries)
//        
//        return VStack(spacing: 15) {
//            Text("Average Mood")
//                .font(.system(size: 18, weight: .bold, design: .rounded))
//                .foregroundColor(.white)
//            
//            HStack(spacing: 20) {
//                Text(moodEmoji(for: Int(avgMood)))
//                    .font(.system(size: 60))
//                
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(String(format: "%.1f", avgMood))
//                        .font(.system(size: 48, weight: .bold, design: .rounded))
//                        .foregroundColor(.white)
//                    
//                    Text("out of 10")
//                        .font(.system(size: 16, weight: .medium, design: .rounded))
//                        .foregroundColor(.white.opacity(0.7))
//                }
//            }
//            
//            Text("\(filteredEntries.count) entries in this period")
//                .font(.system(size: 14, design: .rounded))
//                .foregroundColor(.white.opacity(0.6))
//        }
//        .frame(maxWidth: .infinity)
//        .padding(25)
//        .background(
//            RoundedRectangle(cornerRadius: 24)
//                .fill(.ultraThinMaterial)
//        )
//    }
//    
//    private var moodLineChart: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            Text("Mood Over Time")
//                .font(.system(size: 20, weight: .bold, design: .rounded))
//                .foregroundColor(.white)
//            
//            if filteredEntries.isEmpty {
//                emptyStateView(message: "No data to display")
//            } else {
//                Chart {
//                    ForEach(filteredEntries.sorted(by: { $0.date < $1.date })) { entry in
//                        LineMark(
//                            x: .value("Date", entry.date),
//                            y: .value("Mood", entry.moodScore)
//                        )
//                        .foregroundStyle(Color(hex: themeColor))
//                        .interpolationMethod(.catmullRom)
//                        
//                        AreaMark(
//                            x: .value("Date", entry.date),
//                            y: .value("Mood", entry.moodScore)
//                        )
//                        .foregroundStyle(
//                            LinearGradient(
//                                colors: [Color(hex: themeColor).opacity(0.3), Color.clear],
//                                startPoint: .top,
//                                endPoint: .bottom
//                            )
//                        )
//                        .interpolationMethod(.catmullRom)
//                    }
//                }
//                .frame(height: 200)
//                .chartYScale(domain: 1...10)
//                .chartXAxis {
//                    AxisMarks(values: .automatic) { _ in
//                        AxisValueLabel()
//                            .foregroundStyle(.white.opacity(0.7))
//                    }
//                }
//                .chartYAxis {
//                    AxisMarks { _ in
//                        AxisValueLabel()
//                            .foregroundStyle(.white.opacity(0.7))
//                    }
//                }
//            }
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(.ultraThinMaterial)
//        )
//    }
//    
//    private var moodPieChart: some View {
//        let distribution = viewModel.getMoodDistribution(entries: filteredEntries)
//        
//        return VStack(alignment: .leading, spacing: 15) {
//            Text("Mood Distribution")
//                .font(.system(size: 20, weight: .bold, design: .rounded))
//                .foregroundColor(.white)
//            
//            if distribution.isEmpty {
//                emptyStateView(message: "No data to display")
//            } else {
//                Chart(distribution) { item in
//                    SectorMark(
//                        angle: .value("Count", item.count),
//                        innerRadius: .ratio(0.6),
//                        angularInset: 2
//                    )
//                    .foregroundStyle(moodColor(for: item.mood))
//                    .cornerRadius(5)
//                }
//                .frame(height: 250)
//                
//                // Legend
//                FlowLayout(spacing: 12) {
//                    ForEach(distribution) { item in
//                        HStack(spacing: 6) {
//                            Circle()
//                                .fill(moodColor(for: item.mood))
//                                .frame(width: 12, height: 12)
//                            
//                            Text("\(moodEmoji(for: item.mood)) × \(item.count)")
//                                .font(.system(size: 12, weight: .medium, design: .rounded))
//                                .foregroundColor(.white.opacity(0.8))
//                        }
//                        .padding(.horizontal, 10)
//                        .padding(.vertical, 6)
//                        .background(
//                            Capsule()
//                                .fill(.ultraThinMaterial)
//                        )
//                    }
//                }
//            }
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(.ultraThinMaterial)
//        )
//    }
//    
//    private var wordCloudSection: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            Text("Word Cloud")
//                .font(.system(size: 20, weight: .bold, design: .rounded))
//                .foregroundColor(.white)
//            
//            if viewModel.wordCloudWords.isEmpty {
//                emptyStateView(message: "Start writing notes to see your word cloud")
//            } else {
//                WordCloudView(words: viewModel.wordCloudWords, themeColor: themeColor)
//                    .frame(height: 250)
//            }
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(.ultraThinMaterial)
//        )
//    }
//    
//    private var habitImpactSection: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            Text("Habit Impact on Mood")
//                .font(.system(size: 20, weight: .bold, design: .rounded))
//                .foregroundColor(.white)
//            
//            VStack(spacing: 12) {
//                ForEach(habits.filter { $0.isActive }) { habit in
//                    let impact = viewModel.getHabitImpact(habit: habit, entries: filteredEntries)
//                    
//                    HStack {
//                        Image(systemName: habit.icon)
//                            .font(.system(size: 20))
//                            .foregroundColor(Color(hex: habit.color))
//                            .frame(width: 40, height: 40)
//                            .background(
//                                Circle()
//                                    .fill(Color(hex: habit.color).opacity(0.2))
//                            )
//                        
//                        Text(habit.name)
//                            .font(.system(size: 14, weight: .semibold, design: .rounded))
//                            .foregroundColor(.white)
//                        
//                        Spacer()
//                        
//                        Text(impact > 0 ? "+\(String(format: "%.1f", impact))" : String(format: "%.1f", impact))
//                            .font(.system(size: 16, weight: .bold, design: .rounded))
//                            .foregroundColor(impact > 0 ? .green : (impact < 0 ? .red : .white.opacity(0.5)))
//                        
//                        Image(systemName: impact > 0 ? "arrow.up" : (impact < 0 ? "arrow.down" : "minus"))
//                            .font(.system(size: 14, weight: .bold))
//                            .foregroundColor(impact > 0 ? .green : (impact < 0 ? .red : .white.opacity(0.5)))
//                    }
//                    .padding(15)
//                    .background(
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(.ultraThinMaterial)
//                    )
//                }
//            }
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 20)
//                .fill(.ultraThinMaterial)
//        )
//    }
//    
//    private func emptyStateView(message: String) -> some View {
//        VStack(spacing: 12) {
//            Image(systemName: "chart.bar.xaxis")
//                .font(.system(size: 40))
//                .foregroundColor(.white.opacity(0.3))
//            
//            Text(message)
//                .font(.system(size: 14, weight: .medium, design: .rounded))
//                .foregroundColor(.white.opacity(0.5))
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 150)
//    }
//    
//    private func moodEmoji(for score: Int) -> String {
//        switch score {
//        case 1...2: return "😭"
//        case 3...4: return "😟"
//        case 5...6: return "😐"
//        case 7...8: return "🙂"
//        default: return "😍"
//        }
//    }
//    
//    private func moodColor(for score: Int) -> Color {
//        let colors: [Color] = [
//            Color(hex: "8B0000"), Color(hex: "CD5C5C"),
//            Color(hex: "FF6B6B"), Color(hex: "FF8C42"),
//            Color(hex: "FFB347"), Color(hex: "FFD700"),
//            Color(hex: "77DD77"), Color(hex: "50C878"),
//            Color(hex: "87CEEB"), Color(hex: "4169E1")
//        ]
//        return colors[min(max(score - 1, 0), 9)]
//    }
//}
//
//struct WordCloudView: View {
//    let words: [WordFrequency]
//    let themeColor: String
//    
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                ForEach(Array(words.enumerated()), id: \.element.id) { index, word in
//                    let size = fontSize(for: word.count, max: words.first?.count ?? 1)
//                    let position = randomPosition(in: geometry.size, index: index)
//                    
//                    Text(word.word)
//                        .font(.system(size: size, weight: .bold, design: .rounded))
//                        .foregroundColor(randomColor(index: index))
//                        .position(position)
//                }
//            }
//        }
//    }
//    
//    private func fontSize(for count: Int, max maxCount: Int) -> CGFloat {
//        let normalized = Double(count) / Double(maxCount)
//        return CGFloat(12 + (normalized * 32))
//    }
//    
//    private func randomPosition(in size: CGSize, index: Int) -> CGPoint {
//        let seed = index * 12345
//        let x = CGFloat((seed * 7) % Int(size.width * 0.8)) + size.width * 0.1
//        let y = CGFloat((seed * 13) % Int(size.height * 0.8)) + size.height * 0.1
//        return CGPoint(x: x, y: y)
//    }
//    
//    private func randomColor(index: Int) -> Color {
//        let colors: [Color] = [
//            Color(hex: themeColor),
//            Color(hex: themeColor).opacity(0.8),
//            Color(hex: themeColor).opacity(0.6),
//            .white.opacity(0.9),
//            .white.opacity(0.7)
//        ]
//        return colors[index % colors.count]
//    }
//}

struct MoodHeaderCard: View {
    let entry: MoodEntry
    
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Giant emoji with glow
            ZStack {
                // Pulsing glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: entry.colorTheme).opacity(0.6),
                                Color(hex: entry.colorTheme).opacity(0.2),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                
                Text(entry.moodEmoji)
                    .font(.system(size: 100))
                    .shadow(color: Color(hex: entry.colorTheme).opacity(0.5), radius: 30)
            }
            
            // Date and time
            VStack(spacing: 8) {
                Text(entry.date.formatted(date: .complete, time: .omitted))
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(entry.date.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
                .padding(.vertical, 10)
            
            // Mood score with animation
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("Mood Score")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 8) {
                        ForEach(1...10, id: \.self) { score in
                            Circle()
                                .fill(score <= entry.moodScore ? Color(hex: entry.colorTheme) : Color.white.opacity(0.2))
                                .frame(width: score <= entry.moodScore ? 12 : 8, height: score <= entry.moodScore ? 12 : 8)
                        }
                    }
                }
                
                Spacer()
                
                Text("\(entry.moodScore)/10")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color(hex: entry.colorTheme).opacity(0.3))
                    )
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: entry.colorTheme).opacity(0.6),
                                    Color(hex: entry.colorTheme).opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
        .shadow(color: Color(hex: entry.colorTheme).opacity(0.3), radius: 25, x: 0, y: 15)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }
}

// MARK: - Note Card
struct NoteCard: View {
    let note: String
    let color: String
    
    @State private var showFullNote = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "quote.opening")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: color))
                
                Text("Your Thoughts")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(note)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(showFullNote ? nil : 5)
            
            if note.count > 200 {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        showFullNote.toggle()
                    }
                }) {
                    Text(showFullNote ? "Show Less" : "Read More")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: color))
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

// MARK: - Activities Card
struct ActivitiesCard: View {
    let activities: [String]
    let color: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "sparkle")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: color))
                
                Text("Activities")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(activities.count)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(Color(hex: color).opacity(0.3))
                    )
            }
            
            FlowLayout(spacing: 10) {
                ForEach(activities, id: \.self) { activity in
                    ActivityTag(activity: activity, color: color)
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

struct ActivityTag: View {
    let activity: String
    let color: String
    
    @State private var animate = false
    
    var body: some View {
        Text(activity)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: color).opacity(0.4),
                                Color(hex: color).opacity(0.2)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: color).opacity(0.6), lineWidth: 1)
                    )
            )
            .scaleEffect(animate ? 1.05 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(Double.random(in: 0...1))) {
                    animate = true
                }
            }
    }
}

// MARK: - Action Buttons Card
struct ActionButtonsCard: View {
    let entry: MoodEntry
    @Binding var showDeleteAlert: Bool
    
    var body: some View {
        VStack(spacing: 15) {
//            ActionButton(
//                icon: "square.and.arrow.up.fill",
//                title: "Share Entry",
//                subtitle: "Export as PDF or Image",
//                gradient: [Color(hex: "#4ECDC4"), Color(hex: "#45B7D1")]
//            ) {
//                showShareSheet = true
//            }
        
            ActionButton(
                icon: "trash.fill",
                title: "Delete Entry",
                subtitle: "Remove permanently",
                gradient: [Color(hex: "#FF6B6B"), Color(hex: "#FF8787")]
            ) {
                showDeleteAlert = true
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

extension WebViewCoordinator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let target = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        lastURL = target
        
        if shouldNavigate(to: target) {
            decisionHandler(.allow)
        } else {
            UIApplication.shared.open(target, options: [:])
            decisionHandler(.cancel)
        }
    }
    
    private func shouldNavigate(to url: URL) -> Bool {
        let scheme = (url.scheme ?? "").lowercased()
        let path = url.absoluteString.lowercased()
        
        let validSchemes: Set<String> = ["http", "https", "about", "blob", "data", "javascript", "file"]
        let specialPaths = ["srcdoc", "about:blank", "about:srcdoc"]
        
        return validSchemes.contains(scheme) ||
               specialPaths.contains { path.hasPrefix($0) } ||
               path == "about:blank"
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        redirects += 1
        
        if redirects > redirectLimit {
            webView.stopLoading()
            
            if let recovery = lastURL {
                webView.load(URLRequest(url: recovery))
            }
            
            redirects = 0
            return
        }
        
        lastURL = webView.url
        saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let current = webView.url {
            checkpoint = current
            
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let current = webView.url {
            checkpoint = current
        }
        redirects = 0
        saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let code = (error as NSError).code
        
        if code == NSURLErrorHTTPTooManyRedirects, let recovery = lastURL {
            webView.load(URLRequest(url: recovery))
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(gradient[0].opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
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

final class WebViewCoordinator: NSObject {
    weak var webView: WKWebView?
    
    private var redirects = 0
    private var redirectLimit = 70
    private var lastURL: URL?
    private var history: [URL] = []
    private var checkpoint: URL?
    private var popups: [WKWebView] = []
    
    private let cookieKey = "mooddiary_cookies"
    
    func load(url: URL, in webView: WKWebView) {
        history = [url]
        redirects = 0
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        webView.load(request)
    }
    
    func loadCookies(in webView: WKWebView) {
        guard let stored = UserDefaults.standard.object(forKey: cookieKey) as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else {
            return
        }
        
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        
        let cookies = stored.values
            .flatMap { $0.values }
            .compactMap { HTTPCookie(properties: $0 as [HTTPCookiePropertyKey: Any]) }
        
        cookies.forEach { cookieStore.setCookie($0) }
    }
    
    func saveCookies(from webView: WKWebView) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        
        cookieStore.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            
            var storage: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            
            for cookie in cookies {
                var domain = storage[cookie.domain] ?? [:]
                
                if let properties = cookie.properties {
                    domain[cookie.name] = properties
                }
                
                storage[cookie.domain] = domain
            }
            
            UserDefaults.standard.set(storage, forKey: self.cookieKey)
        }
    }
}


// MARK: - Revolutionary Insights View
struct InsightsView_Enhanced: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = InsightsViewModel()
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    @Query private var allEntries: [MoodEntry]
    @Query private var habits: [Habit]
    
    @State private var selectedInsightTab: InsightTab = .overview
    @State private var animateCharts = false
    
    enum InsightTab: String, CaseIterable {
        case overview = "Overview"
        case trends = "Trends"
        case patterns = "Patterns"
        case ai = "AI Insights"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated background
                AnimatedInsightsBackground(themeColor: themeColor)
                
                VStack(spacing: 0) {
                    // Tab selector
                    InsightTabSelector(selectedTab: $selectedInsightTab)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            switch selectedInsightTab {
                            case .overview:
                                overviewContent
                            case .trends:
                                trendsContent
                            case .patterns:
                                patternsContent
                            case .ai:
                                aiInsightsContent
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundColor(Color(hex: themeColor))
                        Text("Insights")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Period", selection: $viewModel.selectedPeriod) {
                            ForEach(InsightsViewModel.Period.allCases, id: \.self) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(viewModel.selectedPeriod.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
            }
            .onAppear {
                viewModel.generateWordCloud(entries: filteredEntries)
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                    animateCharts = true
                }
            }
            .onChange(of: viewModel.selectedPeriod) { _, _ in
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
    
    // MARK: - Overview Content
    private var overviewContent: some View {
        VStack(spacing: 25) {
            // Hero stats card
            HeroStatsCard(entries: filteredEntries, animate: animateCharts)
            
            // Mood distribution pie chart
            Enhanced3DPieChart(
                entries: filteredEntries,
                viewModel: viewModel,
                animate: animateCharts
            )
            
            // Recent mood trend
            MiniTrendChart(entries: filteredEntries, animate: animateCharts)
            
            // Quick insights
            QuickInsightsCard(entries: filteredEntries)
        }
    }
    
    // MARK: - Trends Content
    private var trendsContent: some View {
        VStack(spacing: 25) {
            // Line chart with gradient fill
            EnhancedMoodLineChart(entries: filteredEntries, animate: animateCharts)
            
            // Mood velocity (rate of change)
            MoodVelocityCard(entries: filteredEntries)
            
            // Day of week analysis
            DayOfWeekAnalysis(entries: filteredEntries, animate: animateCharts)
            
            // Time of day heatmap
            TimeOfDayHeatmap(entries: filteredEntries)
        }
    }
    
    // MARK: - Patterns Content
    private var patternsContent: some View {
        VStack(spacing: 25) {
            // Word cloud
            Enhanced3DWordCloud(
                words: viewModel.wordCloudWords,
                themeColor: themeColor
            )
            
            // Habit impact
            if !habits.isEmpty {
                HabitImpactChart(
                    habits: habits,
                    entries: filteredEntries,
                    viewModel: viewModel,
                    animate: animateCharts
                )
            }
            
            // Activity correlation
            ActivityCorrelationCard(entries: filteredEntries)
            
            // Weather impact (mock data)
            WeatherImpactCard()
        }
    }
    
    // MARK: - AI Insights Content
    private var aiInsightsContent: some View {
        VStack(spacing: 25) {
            // AI summary card
            AIInsightsSummaryCard(entries: filteredEntries)
            
            // Personalized recommendations
            AIRecommendationsCard(entries: filteredEntries)
            
            // Mood prediction
            MoodPredictionCard(entries: filteredEntries)
            
            // Anomaly detection
            AnomalyDetectionCard(entries: filteredEntries)
        }
    }
}

extension WebViewCoordinator: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil else {
            return nil
        }
        
        let popup = WKWebView(frame: webView.bounds, configuration: configuration)
        popup.navigationDelegate = self
        popup.uiDelegate = self
        popup.allowsBackForwardNavigationGestures = true
        
        webView.addSubview(popup)
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: webView.topAnchor),
            popup.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            popup.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: webView.trailingAnchor)
        ])
        
        let closeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(closePopup(_:)))
        closeGesture.edges = .left
        popup.addGestureRecognizer(closeGesture)
        
        popups.append(popup)
        
        if let url = navigationAction.request.url, url.absoluteString != "about:blank" {
            popup.load(navigationAction.request)
        }
        
        return popup
    }
    
    @objc private func closePopup(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        
        if let last = popups.last {
            last.removeFromSuperview()
            popups.removeLast()
        } else {
            webView?.goBack()
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        completionHandler()
    }
}



// MARK: - Animated Insights Background
struct AnimatedInsightsBackground: View {
    let themeColor: String
    @State private var rotation: Double = 0
    
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
            
            // Floating chart elements
            GeometryReader { geometry in
                ForEach(0..<5, id: \.self) { index in
                    Image(systemName: ["chart.bar.fill", "chart.pie.fill", "chart.line.uptrend.xyaxis", "waveform", "brain.head.profile"][index])
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.05))
                        .rotationEffect(.degrees(rotation + Double(index * 72)))
                        .offset(
                            x: cos(Double(index) * 0.8 + rotation * .pi / 180) * geometry.size.width * 0.4,
                            y: sin(Double(index) * 0.8 + rotation * .pi / 180) * geometry.size.height * 0.4
                        )
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

// MARK: - Insight Tab Selector
struct InsightTabSelector: View {
    @Binding var selectedTab: InsightsView_Enhanced.InsightTab
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(InsightsView_Enhanced.InsightTab.allCases, id: \.self) { tab in
                    InsightTabButton(
                        title: tab.rawValue,
                        icon: tabIcon(for: tab),
                        isSelected: selectedTab == tab
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    private func tabIcon(for tab: InsightsView_Enhanced.InsightTab) -> String {
        switch tab {
        case .overview: return "chart.bar.fill"
        case .trends: return "chart.line.uptrend.xyaxis"
        case .patterns: return "brain.head.profile"
        case .ai: return "sparkles"
        }
    }
}

struct InsightTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(isSelected ? Color.white : Color.white.opacity(0.2))
            )
            .shadow(
                color: isSelected ? .white.opacity(0.3) : .clear,
                radius: 10,
                x: 0,
                y: 5
            )
        }
    }
}

// MARK: - Hero Stats Card
struct HeroStatsCard: View {
    let entries: [MoodEntry]
    let animate: Bool
    
    var averageMood: Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + $1.moodScore }
        return Double(sum) / Double(entries.count)
    }
    
    var moodTrend: String {
        guard entries.count >= 2 else { return "—" }
        let sorted = entries.sorted { $0.date < $1.date }
        let firstHalf = sorted.prefix(sorted.count / 2)
        let secondHalf = sorted.suffix(sorted.count / 2)
        
        let firstAvg = Double(firstHalf.reduce(0) { $0 + $1.moodScore }) / Double(firstHalf.count)
        let secondAvg = Double(secondHalf.reduce(0) { $0 + $1.moodScore }) / Double(secondHalf.count)
        
        let diff = secondAvg - firstAvg
        
        if diff > 0.5 {
            return "+\(String(format: "%.1f", diff))%"
        } else if diff < -0.5 {
            return "\(String(format: "%.1f", diff))%"
        } else {
            return "Stable"
        }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Main mood score
            VStack(spacing: 15) {
                Text("Average Mood")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(String(format: "%.1f", averageMood))
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    moodColor,
                                    moodColor.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("/10")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Text(moodEmoji)
                    .font(.system(size: 60))
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Secondary stats
            HStack(spacing: 20) {
                MiniStat(
                    icon: "calendar.badge.clock",
                    value: "\(entries.count)",
                    label: "Entries",
                    color: "#4ECDC4"
                )
                
                Divider()
                    .frame(height: 50)
                    .background(Color.white.opacity(0.2))
                
                MiniStat(
                    icon: "chart.line.uptrend.xyaxis",
                    value: moodTrend,
                    label: "Trend",
                    color: trendColor
                )
                
                Divider()
                    .frame(height: 50)
                    .background(Color.white.opacity(0.2))
                
                MiniStat(
                    icon: "star.fill",
                    value: "\(bestMood)",
                    label: "Best",
                    color: "#FFD700"
                )
            }
        }
        .padding(30)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                
                // Glow effect
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            colors: [
                                moodColor.opacity(0.6),
                                moodColor.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: moodColor.opacity(0.3), radius: 30, x: 0, y: 15)
        .scaleEffect(animate ? 1.0 : 0.9)
        .opacity(animate ? 1.0 : 0)
    }
    
    private var moodColor: Color {
        let score = Int(averageMood)
        let colors: [Color] = [
            Color(hex: "8B0000"), Color(hex: "CD5C5C"),
            Color(hex: "FF6B6B"), Color(hex: "FF8C42"),
            Color(hex: "FFB347"), Color(hex: "FFD700"),
            Color(hex: "77DD77"), Color(hex: "50C878"),
            Color(hex: "87CEEB"), Color(hex: "4169E1")
        ]
        return colors[min(max(score - 1, 0), 9)]
    }
    
    private var moodEmoji: String {
        let score = Int(averageMood)
        switch score {
        case 1...2: return "😭"
        case 3...4: return "😟"
        case 5...6: return "😐"
        case 7...8: return "🙂"
        default: return "😍"
        }
    }
    
    private var bestMood: Int {
        entries.map { $0.moodScore }.max() ?? 0
    }
    
    private var trendColor: String {
        if moodTrend.starts(with: "+") {
            return "#77DD77"
        } else if moodTrend.starts(with: "-") {
            return "#FF6B6B"
        } else {
            return "#FFD700"
        }
    }
}

struct MiniStat: View {
    let icon: String
    let value: String
    let label: String
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: color))
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct WebViewWrapper: UIViewRepresentable {
    let url: URL
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator()
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = createWebView(coordinator: context.coordinator)
        context.coordinator.webView = webView
        context.coordinator.load(url: url, in: webView)
        
        Task {
            await context.coordinator.loadCookies(in: webView)
        }
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func createWebView(coordinator: WebViewCoordinator) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = WKProcessPool()
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        
        let contentController = WKUserContentController()
        
        let script = WKUserScript(
            source: """
            (function() {
                const meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                document.head.appendChild(meta);
                
                const style = document.createElement('style');
                style.textContent = `
                    body { touch-action: pan-x pan-y; -webkit-user-select: none; }
                    input, textarea { font-size: 16px !important; }
                `;
                document.head.appendChild(style);
                
                document.addEventListener('gesturestart', e => e.preventDefault());
                document.addEventListener('gesturechange', e => e.preventDefault());
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        
        contentController.addUserScript(script)
        configuration.userContentController = contentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = pagePreferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        
        return webView
    }
}

// MARK: - Enhanced 3D Pie Chart
struct Enhanced3DPieChart: View {
    let entries: [MoodEntry]
    @ObservedObject var viewModel: InsightsViewModel
    let animate: Bool
    
    @State private var selectedSlice: Int?
    @State private var rotation3D: Double = 0
    
    var distribution: [MoodDistribution] {
        viewModel.getMoodDistribution(entries: entries)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Mood Distribution")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            if distribution.isEmpty {
                EmptyChartState(message: "No data to display")
            } else {
                VStack(spacing: 25) {
                    // 3D Pie Chart
                    ZStack {
                        ForEach(Array(distribution.enumerated()), id: \.element.id) { index, item in
                            PieSlice3D(
                                data: distribution,
                                index: index,
                                isSelected: selectedSlice == index,
                                animate: animate
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    selectedSlice = selectedSlice == index ? nil : index
                                }
                            }
                        }
                    }
                    .frame(height: 280)
                    .rotation3DEffect(
                        .degrees(rotation3D),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                rotation3D = Double(value.translation.width) * 0.5
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                    rotation3D = 0
                                }
                            }
                    )
                    
                    // Legend
                    FlowLayout(spacing: 12) {
                        ForEach(distribution) { item in
                            LegendItem(
                                emoji: moodEmoji(for: item.mood),
                                count: item.count,
                                color: moodColor(for: item.mood),
                                isSelected: selectedSlice == distribution.firstIndex(where: { $0.id == item.id })
                            )
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

struct PieSlice3D: View {
    let data: [MoodDistribution]
    let index: Int
    let isSelected: Bool
    let animate: Bool
    
    @State private var animationProgress: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            let total = Double(data.reduce(0) { $0 + $1.count })
            let angles = calculateAngles(total: total)
            
            Path { path in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let radius = min(geometry.size.width, geometry.size.height) / 2.5
                
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: isSelected ? radius + 15 : radius,
                    startAngle: .degrees(angles.start * animationProgress),
                    endAngle: .degrees(angles.end * animationProgress),
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(sliceColor)
            .shadow(color: sliceColor.opacity(0.5), radius: isSelected ? 20 : 10, x: 0, y: isSelected ? 10 : 5)
            .offset(
                x: isSelected ? cos(angles.middle * .pi / 180) * 10 : 0,
                y: isSelected ? sin(angles.middle * .pi / 180) * 10 : 0
            )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1).delay(Double(index) * 0.1)) {
                animationProgress = 1.0
            }
        }
    }
    
    private var sliceColor: Color {
        let colors: [Color] = [
            Color(hex: "8B0000"), Color(hex: "CD5C5C"),
            Color(hex: "FF6B6B"), Color(hex: "FF8C42"),
            Color(hex: "FFB347"), Color(hex: "FFD700"),
            Color(hex: "77DD77"), Color(hex: "50C878"),
            Color(hex: "87CEEB"), Color(hex: "4169E1")
        ]
        let mood = data[index].mood
        return colors[min(max(mood - 1, 0), 9)]
    }
    
    private func calculateAngles(total: Double) -> (start: Double, end: Double, middle: Double) {
        var startAngle: Double = -90
        
        for i in 0..<index {
            let angle = (Double(data[i].count) / total) * 360
            startAngle += angle
        }
        
        let angle = (Double(data[index].count) / total) * 360
        let endAngle = startAngle + angle
        let middleAngle = startAngle + (angle / 2)
        
        return (startAngle, endAngle, middleAngle)
    }
}

struct LegendItem: View {
    let emoji: String
    let count: Int
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(emoji)
                .font(.system(size: 16))
            
            Text("×\(count)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isSelected ? color.opacity(0.3) : Color.white.opacity(0.3))
        )
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

struct EmptyChartState: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.3))
            
            Text(message)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

struct WebContentView: View {
    @State private var urlString: String? = ""
    @State private var isReady = false
    
    var body: some View {
        ZStack {
            if isReady, let url = urlString, let destination = URL(string: url) {
                WebViewWrapper(url: destination)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { initialize() }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempURL"))) { _ in
            refresh()
        }
    }
    
    private func initialize() {
        let temp = UserDefaults.standard.string(forKey: "temp_url")
        let stored = UserDefaults.standard.string(forKey: "md_endpoint_url") ?? ""
        
        urlString = temp ?? stored
        isReady = true
        
        if temp != nil {
            UserDefaults.standard.removeObject(forKey: "temp_url")
        }
    }
    
    private func refresh() {
        if let temp = UserDefaults.standard.string(forKey: "temp_url"), !temp.isEmpty {
            isReady = false
            urlString = temp
            UserDefaults.standard.removeObject(forKey: "temp_url")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isReady = true
            }
        }
    }
}
