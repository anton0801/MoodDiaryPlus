import SwiftUI


struct AIInsightsSummaryCard: View {
    let entries: [MoodEntry]
    
    @State private var isGenerating = false
    @State private var showInsights = false
    
    var aiSummary: String {
        guard !entries.isEmpty else { return "Start logging to get AI insights!" }
        
        let avgMood = Double(entries.reduce(0) { $0 + $1.moodScore }) / Double(entries.count)
        
        var summary = ""
        
        // Analyze mood trend
        if avgMood >= 7 {
            summary += "Your mood has been consistently positive! "
        } else if avgMood <= 4 {
            summary += "Your mood shows room for improvement. "
        } else {
            summary += "Your mood has been moderate. "
        }
        
        // Analyze consistency
        let calendar = Calendar.current
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.date) })
        if uniqueDays.count >= 10 {
            summary += "Your journaling consistency is excellent, which helps track patterns effectively. "
        }
        
        // Analyze activities
        let allActivities = entries.flatMap { $0.selectedActivities }
        if !allActivities.isEmpty {
            let grouped = Dictionary(grouping: allActivities, by: { $0 })
            if let topActivity = grouped.max(by: { $0.value.count < $1.value.count }) {
                summary += "You frequently engage in \(topActivity.key), which appears to be a consistent part of your routine. "
            }
        }
        
        return summary
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#A78BFA"),
                                    Color(hex: "#8B5CF6")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Summary")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Powered by advanced analysis")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
            
            if isGenerating {
                HStack(spacing: 15) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#8B5CF6")))
                    
                    Text("Analyzing your patterns...")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else if showInsights {
                VStack(alignment: .leading, spacing: 15) {
                    Text(aiSummary)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .lineSpacing(6)
                    
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(Color(hex: "#FFD700"))
                        
                        Text("Based on \(entries.count) entries")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.top, 10)
                }
            } else {
                Button(action: {
                    generateInsights()
                }) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 20))
                        
                        Text("Generate AI Insights")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: "#A78BFA"),
                                Color(hex: "#8B5CF6")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color(hex: "#8B5CF6").opacity(0.4), radius: 15, x: 0, y: 8)
                }
            }
        }
        .padding(25)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "#A78BFA").opacity(0.5),
                                Color(hex: "#8B5CF6").opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: Color(hex: "#8B5CF6").opacity(0.2), radius: 25, x: 0, y: 15)
    }
    
    private func generateInsights() {
        isGenerating = true
        
        // Simulate AI processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isGenerating = false
                showInsights = true
            }
        }
    }
}

// MARK: - AI Recommendations Card
struct AIRecommendationsCard: View {
    let entries: [MoodEntry]
    
    var recommendations: [(icon: String, title: String, description: String, color: String)] {
        var recs: [(String, String, String, String)] = []
        
        guard !entries.isEmpty else {
            return [
                ("pencil.and.list.clipboard", "Start Journaling", "Log your first mood entry to get personalized recommendations", "#4ECDC4")
            ]
        }
        
        let avgMood = Double(entries.reduce(0) { $0 + $1.moodScore }) / Double(entries.count)
        
        // Activity recommendations
        let allActivities = entries.flatMap { $0.selectedActivities }
        let activityCounts = Dictionary(grouping: allActivities, by: { $0 }).mapValues { $0.count }
        
        if activityCounts["Workout"] ?? 0 < entries.count / 3 {
            recs.append(("figure.run", "Try More Exercise", "Physical activity is linked to improved mood", "#E74C3C"))
        }
        
        if activityCounts["Sleep"] ?? 0 < entries.count / 2 {
            recs.append(("bed.double.fill", "Focus on Sleep", "Better sleep can significantly improve your mood", "#9B59B6"))
        }
        
        // Consistency recommendation
        let calendar = Calendar.current
        let uniqueDays = Set(entries.map { calendar.startOfDay(for: $0.date) })
        if Double(uniqueDays.count) / Double(entries.count) < 0.7 {
            recs.append(("calendar.badge.clock", "Log Daily", "Consistent tracking helps identify patterns", "#3498DB"))
        }
        
        // Mood-based recommendations
        if avgMood < 6 {
            recs.append(("heart.fill", "Self-Care Time", "Consider activities that bring you joy", "#FF6B6B"))
        }
        
        // Social interaction
        if activityCounts["Friends"] ?? 0 < entries.count / 4 {
            recs.append(("person.2.fill", "Connect with Others", "Social connections are vital for wellbeing", "#4ECDC4"))
        }
        
        return Array(recs.prefix(4))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#FFD700"))
                
                Text("Personalized Recommendations")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(recommendations.enumerated()), id: \.offset) { index, rec in
                    RecommendationRow(
                        icon: rec.icon,
                        title: rec.title,
                        description: rec.description,
                        color: rec.color,
                        index: index
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
}

struct RecommendationRow: View {
    let icon: String
    let title: String
    let description: String
    let color: String
    let index: Int
    
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: color).opacity(0.4),
                                Color(hex: color).opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color(hex: color))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: color).opacity(0.6))
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .offset(x: appeared ? 0 : 50)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1)) {
                appeared = true
            }
        }
    }
}

// MARK: - Mood Prediction Card
struct MoodPredictionCard: View {
    let entries: [MoodEntry]
    
    @State private var showPrediction = false
    
    var predictedMood: Double {
        guard entries.count >= 3 else { return 5.0 }
        
        // Simple linear regression prediction
        let sorted = entries.sorted { $0.date < $1.date }.suffix(7)
        let weights = [0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4]
        
        var prediction = 0.0
        for (index, entry) in sorted.enumerated() {
            let weight = index < weights.count ? weights[index] : 0.4
            prediction += Double(entry.moodScore) * weight
        }
        
        return min(max(prediction / weights.reduce(0, +), 1), 10)
    }
    
    var confidence: Double {
        // Calculate confidence based on data consistency
        guard entries.count >= 5 else { return 0.3 }
        
        let recent = entries.sorted { $0.date < $1.date }.suffix(7)
        let moods = recent.map { Double($0.moodScore) }
        
        // Calculate standard deviation
        let mean = moods.reduce(0, +) / Double(moods.count)
        let variance = moods.reduce(0) { $0 + pow($1 - mean, 2) } / Double(moods.count)
        let stdDev = sqrt(variance)
        
        // Lower std dev = higher confidence
        return max(0.3, min(1.0, 1.0 - (stdDev / 5)))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#EC4899"),
                                    Color(hex: "#DB2777")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "crystal.ball.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Mood Prediction")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Next 24 hours forecast")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
            
            if entries.count < 3 {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("Need at least 3 entries for prediction")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                VStack(spacing: 20) {
                    // Prediction gauge
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 20)
                            .frame(width: 160, height: 160)
                        
                        Circle()
                            .trim(from: 0, to: showPrediction ? predictedMood / 10 : 0)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#EC4899"),
                                        Color(hex: "#DB2777")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 8) {
                            Text(String(format: "%.1f", showPrediction ? predictedMood : 0))
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("/ 10")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Confidence indicator
                    VStack(spacing: 10) {
                        HStack {
                            Text("Confidence")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                            
                            Spacer()
                            
                            Text("\(Int(confidence * 100))%")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.white.opacity(0.1))
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(hex: "#EC4899"),
                                                Color(hex: "#DB2777")
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: showPrediction ? geometry.size.width * confidence : 0)
                            }
                        }
                        .frame(height: 8)
                    }
                    
                    // Disclaimer
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Predictions are based on your recent patterns and may vary")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
        }
        .padding(25)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "#EC4899").opacity(0.5),
                                Color(hex: "#DB2777").opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: Color(hex: "#EC4899").opacity(0.2), radius: 25, x: 0, y: 15)
        .onAppear {
            withAnimation(.spring(response: 1, dampingFraction: 0.7).delay(0.3)) {
                showPrediction = true
            }
        }
    }
}

// MARK: - Anomaly Detection Card
struct AnomalyDetectionCard: View {
    let entries: [MoodEntry]
    
    var anomalies: [(date: Date, mood: Int, reason: String)] {
        guard entries.count >= 5 else { return [] }
        
        let sorted = entries.sorted { $0.date < $1.date }
        let moods = sorted.map { Double($0.moodScore) }
        let mean = moods.reduce(0, +) / Double(moods.count)
        let variance = moods.reduce(0) { $0 + pow($1 - mean, 2) } / Double(moods.count)
        let stdDev = sqrt(variance)
        
        var detected: [(Date, Int, String)] = []
        
        for entry in sorted {
            let deviation = abs(Double(entry.moodScore) - mean)
            
            if deviation > stdDev * 2 {
                let reason: String
                if entry.moodScore > Int(mean) {
                    reason = "Unusually high mood"
                } else {
                    reason = "Unusually low mood"
                }
                detected.append((entry.date, entry.moodScore, reason))
            }
        }
        
        return Array(detected.suffix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "#F59E0B"),
                                    Color(hex: "#D97706")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Anomaly Detection")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Unusual mood patterns")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
            }
            
            if entries.count < 5 {
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.doc.horizontal")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("Need at least 5 entries to detect anomalies")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else if anomalies.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Color(hex: "#77DD77"))
                    
                    Text("No anomalies detected")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Your mood patterns are consistent")
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                VStack(spacing: 12) {
                    ForEach(anomalies, id: \.date) { anomaly in
                        AnomalyRow(
                            date: anomaly.date,
                            mood: anomaly.mood,
                            reason: anomaly.reason
                        )
                    }
                }
            }
        }
        .padding(25)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 25)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(hex: "#F59E0B").opacity(0.5),
                                Color(hex: "#D97706").opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: Color(hex: "#F59E0B").opacity(0.2), radius: 25, x: 0, y: 15)
    }
}

struct AnomalyRow: View {
    let date: Date
    let mood: Int
    let reason: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#F59E0B").opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text("\(mood)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#F59E0B"))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(reason)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "arrow.right")
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
    }
}
