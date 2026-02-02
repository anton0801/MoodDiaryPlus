import SwiftUI
import SwiftData

struct InteractiveActivitiesGrid: View {
    @ObservedObject var viewModel: TodayViewModel
    @State private var animatedActivities: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkle")
                        .foregroundColor(Color(hex: "96E6B3"))
                    
                    Text("Activities")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(viewModel.selectedActivities.count) selected")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
            }
            
            // Staggered grid with physics-based animations
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                ForEach(Array(viewModel.activities.enumerated()), id: \.element.id) { index, activity in
                    InteractiveActivityButton(
                        activity: activity,
                        isSelected: viewModel.selectedActivities.contains(activity.name),
                        isAnimated: animatedActivities.contains(activity.name)
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            viewModel.toggleActivity(activity.name)
                            animatedActivities.insert(activity.name)
                            
                            // Remove animation state after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                animatedActivities.remove(activity.name)
                            }
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

struct InteractiveActivityButton: View {
    let activity: Activity
    let isSelected: Bool
    let isAnimated: Bool
    let action: () -> Void
    
    @State private var particlesBurst = false
    @State private var glowIntensity: CGFloat = 0
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
            
            // Trigger particle burst
            particlesBurst = true
            withAnimation(.easeOut(duration: 0.8)) {
                particlesBurst = false
            }
        }) {
            ZStack {
                // Particle burst effect
                if particlesBurst {
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(Color(hex: activity.color))
                            .frame(width: 4, height: 4)
                            .offset(
                                x: cos(Double(index) * .pi / 4) * (particlesBurst ? 30 : 0),
                                y: sin(Double(index) * .pi / 4) * (particlesBurst ? 30 : 0)
                            )
                            .opacity(particlesBurst ? 0 : 1)
                    }
                }
                
                VStack(spacing: 10) {
                    // Icon with glow effect
                    ZStack {
                        // Glow layer
                        if isSelected {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(hex: activity.color).opacity(0.6),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 30
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .scaleEffect(1.0 + glowIntensity)
                        }
                        
                        Image(systemName: activity.icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(isSelected ? .white : Color(hex: activity.color))
                    }
                    
                    Text(activity.name)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 85)
                .background(
                    ZStack {
                        // Base background
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isSelected ? Color(hex: activity.color) : Color.white.opacity(0.3))
                        
                        // Shimmer effect for selected items
                        if isSelected {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            .clear,
                                            .white.opacity(0.2),
                                            .clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        // Border
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                Color(hex: activity.color).opacity(isSelected ? 0.8 : 0.4),
                                lineWidth: isSelected ? 2 : 1
                            )
                    }
                )
                .shadow(
                    color: isSelected ? Color(hex: activity.color).opacity(0.5) : .clear,
                    radius: isSelected ? 12 : 0,
                    x: 0,
                    y: isSelected ? 6 : 0
                )
                .scaleEffect(isAnimated ? 1.15 : 1.0)
                .rotation3DEffect(
                    .degrees(isAnimated ? 10 : 0),
                    axis: (x: 1, y: 0, z: 0)
                )
            }
        }
        .buttonStyle(PressableButtonStyle())
        .onAppear {
            if isSelected {
                startGlowAnimation()
            }
        }
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                startGlowAnimation()
            }
        }
    }
    
    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowIntensity = 0.2
        }
    }
}

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Morphing Save Button
struct MorphingSaveButton: View {
    @ObservedObject var viewModel: TodayViewModel
    let modelContext: ModelContext
    
    @State private var isProcessing = false
    @State private var successWave: CGFloat = 0
    @State private var morphProgress: CGFloat = 0
    
    var body: some View {
        Button(action: saveEntry) {
            ZStack {
                // Background morphing shape
                MorphingShape(progress: morphProgress)
                    .fill(
                        viewModel.canSave ?
                        LinearGradient(
                            colors: [
                                viewModel.moodColor,
                                viewModel.moodColor.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                Color.gray.opacity(0.4),
                                Color.gray.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 65)
                    .shadow(
                        color: viewModel.canSave ? viewModel.moodColor.opacity(0.5) : .clear,
                        radius: 20,
                        x: 0,
                        y: 10
                    )
                
                // Success wave effect
                if isProcessing {
                    Wave(progress: successWave)
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 65)
                        .clipShape(MorphingShape(progress: morphProgress))
                }
                
                // Content
                HStack(spacing: 12) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.2)
                    } else if viewModel.showSaveConfetti {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: viewModel.canSave ? "checkmark.seal.fill" : "lock.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .symbolEffect(.bounce, value: viewModel.canSave)
                    }
                    
                    Text(buttonText)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
        }
        .disabled(!viewModel.canSave || isProcessing)
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.canSave)
        .onAppear {
            startMorphAnimation()
        }
    }
    
    private var buttonText: String {
        if isProcessing {
            return "Saving..."
        } else if viewModel.showSaveConfetti {
            return "Saved!"
        } else if !viewModel.canSave {
            return "Add Photo to Continue"
        } else {
            return "Save Entry"
        }
    }
    
    private func saveEntry() {
        isProcessing = true
        
        // Wave animation
        withAnimation(.easeInOut(duration: 0.8)) {
            successWave = 1.0
        }
        
        // Save with delay for animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            viewModel.saveEntry(modelContext: modelContext)
            isProcessing = false
            successWave = 0
        }
    }
    
    private func startMorphAnimation() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            morphProgress = 1.0
        }
    }
}

// MARK: - Morphing Shape
struct MorphingShape: Shape {
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        
        // Create morphing rounded rectangle
        let cornerRadius = 20 + (progress * 10)
        let midY = height / 2
        
        path.move(to: CGPoint(x: cornerRadius, y: 0))
        
        // Top edge with wave
        path.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        
        // Right edge
        path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
        path.addArc(
            center: CGPoint(x: width - cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        // Bottom edge
        path.addLine(to: CGPoint(x: cornerRadius, y: height))
        path.addArc(
            center: CGPoint(x: cornerRadius, y: height - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        // Left edge
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        
        return path
    }
}

// MARK: - Wave Animation
struct Wave: Shape {
    var progress: CGFloat
    
    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let waveHeight: CGFloat = 15
        
        let yOffset = height * (1 - progress)
        
        path.move(to: CGPoint(x: 0, y: yOffset))
        
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin(relativeX * .pi * 4 + progress * .pi * 2)
            let y = yOffset + sine * waveHeight
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()
        
        return path
    }
}

struct StreakButton: View {
    @Query var allEntries: [MoodEntry]
    @State var showStreakDetail = false
    @State var flameAnimation = false
    
    var currentStreak: Int {
        DataManager.shared.calculateStreak(entries: allEntries)
    }
    
    var body: some View {
        Button(action: {
            showStreakDetail = true
        }) {
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .scaleEffect(flameAnimation ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: flameAnimation)
                
                Text("\(currentStreak)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(Color.orange.opacity(0.5), lineWidth: 1)
                    )
            )
        }
        .sheet(isPresented: $showStreakDetail) {
            StreakDetailView(streak: currentStreak, entries: allEntries)
        }
        .onAppear {
            flameAnimation = true
        }
    }
}

// MARK: - Streak Detail View
struct StreakDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let streak: Int
    let entries: [MoodEntry]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "FF6B6B").opacity(0.3),
                        Color(hex: "1a1a2e")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Flame animation
                        ZStack {
                            ForEach(0..<3, id: \.self) { index in
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 100))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .offset(y: CGFloat(index) * -10)
                                    .opacity(1.0 - Double(index) * 0.3)
                            }
                        }
                        .shadow(color: .orange.opacity(0.6), radius: 30)
                        
                        VStack(spacing: 10) {
                            Text("\(streak)")
                                .font(.system(size: 72, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Day Streak")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        // Stats
                        VStack(spacing: 20) {
                            StatRow(
                                icon: "calendar.badge.clock",
                                title: "Total Entries",
                                value: "\(entries.count)",
                                color: "#4ECDC4"
                            )
                            
                            StatRow(
                                icon: "chart.line.uptrend.xyaxis",
                                title: "Average Mood",
                                value: String(format: "%.1f/10", averageMood),
                                color: "#FFD700"
                            )
                            
                            StatRow(
                                icon: "trophy.fill",
                                title: "Longest Streak",
                                value: "\(longestStreak) days",
                                color: "#FF6B6B"
                            )
                        }
                        .padding(25)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal)
                        
                        // Motivational message
                        VStack(spacing: 15) {
                            Image(systemName: motivationalIcon)
                                .font(.system(size: 40))
                                .foregroundColor(Color(hex: "#96E6B3"))
                            
                            Text(motivationalMessage)
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(30)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.ultraThinMaterial)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 30)
                }
            }
            .navigationTitle("Your Progress")
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
    
    private var averageMood: Double {
        guard !entries.isEmpty else { return 0 }
        let sum = entries.reduce(0) { $0 + $1.moodScore }
        return Double(sum) / Double(entries.count)
    }
    
    private var longestStreak: Int {
        // Calculate longest streak from entries
        var longest = 0
        var current = 0
        let calendar = Calendar.current
        let sortedEntries = entries.sorted { $0.date > $1.date }
        
        for (index, entry) in sortedEntries.enumerated() {
            if index == 0 {
                current = 1
            } else {
                let prevDate = sortedEntries[index - 1].date
                let daysDiff = calendar.dateComponents([.day], from: entry.date, to: prevDate).day ?? 0
                
                if daysDiff == 1 {
                    current += 1
                } else {
                    longest = max(longest, current)
                    current = 1
                }
            }
        }
        
        return max(longest, current)
    }
    
    private var motivationalMessage: String {
        switch streak {
        case 0:
            return "Start your journey today! 🌟"
        case 1...3:
            return "Great start! Keep it going! 💪"
        case 4...7:
            return "You're building a habit! 🚀"
        case 8...14:
            return "Incredible consistency! 🌈"
        case 15...30:
            return "You're unstoppable! ⭐️"
        case 31...60:
            return "Legendary dedication! 🏆"
        default:
            return "You're a MoodDiary master! 👑"
        }
    }
    
    private var motivationalIcon: String {
        switch streak {
        case 0...3: return "star.fill"
        case 4...7: return "bolt.fill"
        case 8...14: return "sparkles"
        case 15...30: return "crown.fill"
        default: return "trophy.fill"
        }
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(hex: color))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color(hex: color).opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: UUID
    let color: Color
    let shape: String
    let startX: CGFloat
    let startY: CGFloat
    let size: CGFloat
    let rotation: Double
    let duration: Double
}

struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    @State private var yPosition: CGFloat = 0
    @State private var xPosition: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Group {
            switch piece.shape {
            case "circle":
                Circle()
                    .fill(piece.color)
            case "square":
                Rectangle()
                    .fill(piece.color)
            case "triangle":
                Triangle()
                    .fill(piece.color)
            case "star":
                Star()
                    .fill(piece.color)
            default:
                Circle()
                    .fill(piece.color)
            }
        }
        .frame(width: piece.size, height: piece.size)
        .rotationEffect(.degrees(rotation))
        .position(x: xPosition, y: yPosition)
        .opacity(opacity)
        .onAppear {
            xPosition = piece.startX
            yPosition = piece.startY
            rotation = piece.rotation
            
            withAnimation(.easeOut(duration: piece.duration)) {
                yPosition = UIScreen.main.bounds.height + 100
                xPosition += CGFloat.random(in: -100...100)
                rotation += Double.random(in: -720...720)
            }
            
            withAnimation(.easeIn(duration: piece.duration * 0.7).delay(piece.duration * 0.3)) {
                opacity = 0
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Star: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.4
        let numberOfPoints = 5
        
        for i in 0..<numberOfPoints * 2 {
            let angle = Double(i) * .pi / Double(numberOfPoints) - .pi / 2
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * radius
            let y = center.y + CGFloat(sin(angle)) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Success Animation Overlay
struct SuccessAnimationOverlay: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Radial burst
            ForEach(0..<12, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4ECDC4"), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 100, height: 4)
                    .offset(x: 50)
                    .rotationEffect(.degrees(Double(index) * 30 + rotation))
                    .opacity(opacity)
            }
            
            // Checkmark
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "4ECDC4"), Color(hex: "45B7D1")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: "4ECDC4").opacity(0.6), radius: 30)
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                scale = 1.2
                opacity = 1.0
            }
            
            withAnimation(.linear(duration: 0.5)) {
                rotation = 360
            }
            
            withAnimation(.easeOut(duration: 0.3).delay(1.5)) {
                scale = 0.5
                opacity = 0
            }
        }
    }
}

// MARK: - Enhanced Camera View
struct EnhancedCameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.cameraDevice = .front
        
        // Custom camera overlay (optional)
        if let overlayView = createCameraOverlay() {
            picker.cameraOverlayView = overlayView
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createCameraOverlay() -> UIView? {
        let overlayView = UIView(frame: UIScreen.main.bounds)
        overlayView.backgroundColor = .clear
        
        // Add custom UI elements
        let guideCircle = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        guideCircle.center = CGPoint(x: overlayView.bounds.midX, y: overlayView.bounds.midY - 50)
        guideCircle.layer.cornerRadius = 150
        guideCircle.layer.borderWidth = 3
        guideCircle.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        overlayView.addSubview(guideCircle)
        
        // Instruction label
        let label = UILabel(frame: CGRect(x: 20, y: 100, width: overlayView.bounds.width - 40, height: 60))
        label.text = "Center your face in the circle"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .white
        label.numberOfLines = 2
        label.shadowColor = UIColor.black.withAlphaComponent(0.5)
        label.shadowOffset = CGSize(width: 0, height: 2)
        overlayView.addSubview(label)
        
        return overlayView
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: EnhancedCameraView
        
        init(_ parent: EnhancedCameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Enhanced Photo Filter View
struct EnhancedPhotoFilterView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage
    let onSave: (UIImage) -> Void
    
    @State private var selectedFilter: FilterType = .none
    @State private var brightness: Double = 0
    @State private var contrast: Double = 1
    @State private var saturation: Double = 1
    @State private var temperature: Double = 0
    @State private var vignette: Double = 0
    @State private var filteredImage: UIImage?
    @State private var isProcessing = false
    
    let context = CIContext()
    
    enum FilterType: String, CaseIterable {
        case none = "Original"
        case vivid = "Vivid"
        case warm = "Warm"
        case cool = "Cool"
        case dramatic = "Dramatic"
        case vintage = "Vintage"
        case noir = "Noir"
        case dreamy = "Dreamy"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1a1a2e")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Image preview with comparison slider
                    ZStack {
                        if let filtered = filteredImage {
                            Image(uiImage: filtered)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                        }
                        
                        if isProcessing {
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                    .background(Color.black)
                    
                    ScrollView {
                        VStack(spacing: 25) {
                            // Filter presets
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Filters")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(FilterType.allCases, id: \.self) { filter in
                                            FilterPresetButton(
                                                title: filter.rawValue,
                                                isSelected: selectedFilter == filter
                                            ) {
                                                selectedFilter = filter
                                                applyFilter(filter)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            
                            // Advanced controls
                            VStack(alignment: .leading, spacing: 20) {
                                Text("Adjust")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                VStack(spacing: 15) {
                                    EnhancedFilterSlider(
                                        title: "Brightness",
                                        value: $brightness,
                                        range: -0.5...0.5,
                                        icon: "sun.max.fill",
                                        color: Color(hex: "FFD700")
                                    )
                                    
                                    EnhancedFilterSlider(
                                        title: "Contrast",
                                        value: $contrast,
                                        range: 0.5...1.5,
                                        icon: "circle.lefthalf.filled",
                                        color: Color(hex: "4ECDC4")
                                    )
                                    
                                    EnhancedFilterSlider(
                                        title: "Saturation",
                                        value: $saturation,
                                        range: 0...2,
                                        icon: "paintpalette.fill",
                                        color: Color(hex: "FF6B6B")
                                    )
                                    
                                    EnhancedFilterSlider(
                                        title: "Temperature",
                                        value: $temperature,
                                        range: -0.5...0.5,
                                        icon: "thermometer",
                                        color: Color(hex: "FF8C42")
                                    )
                                    
                                    EnhancedFilterSlider(
                                        title: "Vignette",
                                        value: $vignette,
                                        range: 0...1,
                                        icon: "circle.dashed",
                                        color: Color(hex: "96E6B3")
                                    )
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(hex: "16213e"))
                            .ignoresSafeArea(edges: .bottom)
                    )
                }
            }
            .navigationTitle("Edit Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if let filtered = filteredImage {
                            onSave(filtered)
                        }
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                            Text("Save")
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "4ECDC4"))
                    }
                }
            }
            .onAppear {
                filteredImage = image
            }
            .onChange(of: brightness) { _, _ in applyManualAdjustments() }
            .onChange(of: contrast) { _, _ in applyManualAdjustments() }
            .onChange(of: saturation) { _, _ in applyManualAdjustments() }
            .onChange(of: temperature) { _, _ in applyManualAdjustments() }
            .onChange(of: vignette) { _, _ in applyManualAdjustments() }
        }
    }
    
    private func applyFilter(_ filterType: FilterType) {
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let ciImage = CIImage(image: image) else {
                DispatchQueue.main.async {
                    isProcessing = false
                }
                return
            }
            
            var outputImage = ciImage
            
            // Apply preset filter
            switch filterType {
            case .none:
                break
            case .vivid:
                brightness = 0.1
                contrast = 1.2
                saturation = 1.4
            case .warm:
                temperature = 0.3
                saturation = 1.1
            case .cool:
                temperature = -0.3
                saturation = 1.1
            case .dramatic:
                contrast = 1.4
                vignette = 0.5
            case .vintage:
                saturation = 0.7
                temperature = 0.2
                vignette = 0.3
            case .noir:
                saturation = 0
                contrast = 1.3
            case .dreamy:
                brightness = 0.2
                saturation = 0.8
                vignette = 0.4
            }
            
            DispatchQueue.main.async {
                applyManualAdjustments()
            }
        }
    }
    
    private func applyManualAdjustments() {
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let ciImage = CIImage(image: image) else {
                DispatchQueue.main.async {
                    isProcessing = false
                }
                return
            }
            
            var outputImage = ciImage
            
            // Color controls
            let colorFilter = CIFilter.colorControls()
            colorFilter.inputImage = outputImage
            colorFilter.brightness = Float(brightness)
            colorFilter.contrast = Float(contrast)
            colorFilter.saturation = Float(saturation)
            outputImage = colorFilter.outputImage ?? outputImage
            
            // Temperature
            if temperature != 0 {
                let tempFilter = CIFilter.temperatureAndTint()
                tempFilter.inputImage = outputImage
                tempFilter.neutral = CIVector(x: 6500 + (temperature * 3000), y: 0)
                outputImage = tempFilter.outputImage ?? outputImage
            }
            
            // Vignette
            if vignette > 0 {
                let vignetteFilter = CIFilter.vignette()
                vignetteFilter.inputImage = outputImage
                vignetteFilter.intensity = Float(vignette)
                outputImage = vignetteFilter.outputImage ?? outputImage
            }
            
            // Render final image
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                let finalImage = UIImage(cgImage: cgImage)
                
                DispatchQueue.main.async {
                    filteredImage = finalImage
                    isProcessing = false
                }
            } else {
                DispatchQueue.main.async {
                    isProcessing = false
                }
            }
        }
    }
}

struct FilterPresetButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color.white.opacity(0.2))
                )
        }
    }
}

struct EnhancedFilterSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.2f", value))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .monospacedDigit()
            }
            
            Slider(value: $value, in: range)
                .tint(color)
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
    }
}
