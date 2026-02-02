// Views/Onboarding/OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    @State private var backgroundRotation: Double = 0
    
    var body: some View {
        if hasCompletedOnboarding {
            ContentView()
        } else {
            ZStack {
                // Dynamic 3D background
                Dynamic3DBackground(page: currentPage, rotation: backgroundRotation)
                
                TabView(selection: $currentPage) {
                    OnboardingPage1_Enhanced()
                        .tag(0)
                    OnboardingPage2_Enhanced()
                        .tag(1)
                    OnboardingPage3_Enhanced()
                        .tag(2)
                    OnboardingPage4_Enhanced()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                VStack {
                    Spacer()
                    
                    // Custom animated page indicator
                    CustomPageIndicator(currentPage: currentPage, totalPages: 4)
                        .padding(.bottom, 20)
                    
                    // Morphing action button
                    MorphingButton(currentPage: currentPage) {
                        if currentPage < 3 {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                hasCompletedOnboarding = true
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
            .onChange(of: currentPage) { _, _ in
                withAnimation(.easeInOut(duration: 1)) {
                    backgroundRotation += 90
                }
            }
        }
    }
}

// MARK: - Dynamic 3D Background
struct Dynamic3DBackground: View {
    let page: Int
    let rotation: Double
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: gradientColors(for: page),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating 3D shapes
            GeometryReader { geometry in
                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 30)
                        .fill(
                            LinearGradient(
                                colors: [
                                    shapeColor(for: page).opacity(0.3),
                                    shapeColor(for: page).opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 40)
                        .rotationEffect(.degrees(rotation + Double(index * 45)))
                        .offset(
                            x: cos(Double(index) * 1.2) * geometry.size.width * 0.3,
                            y: sin(Double(index) * 1.2) * geometry.size.height * 0.3
                        )
                }
            }
        }
    }
    
    private func gradientColors(for page: Int) -> [Color] {
        switch page {
        case 0: return [Color(hex: "667eea"), Color(hex: "764ba2")]
        case 1: return [Color(hex: "f093fb"), Color(hex: "f5576c")]
        case 2: return [Color(hex: "4facfe"), Color(hex: "00f2fe")]
        case 3: return [Color(hex: "43e97b"), Color(hex: "38f9d7")]
        default: return [Color(hex: "667eea"), Color(hex: "764ba2")]
        }
    }
    
    private func shapeColor(for page: Int) -> Color {
        switch page {
        case 0: return Color(hex: "764ba2")
        case 1: return Color(hex: "f5576c")
        case 2: return Color(hex: "00f2fe")
        case 3: return Color(hex: "38f9d7")
        default: return Color(hex: "764ba2")
        }
    }
}

// MARK: - Enhanced Page 1: Welcome with Emoji Explosion
struct OnboardingPage1_Enhanced: View {
    @State private var emojis: [EmojiParticle] = []
    @State private var titleScale: CGFloat = 0.5
    @State private var titleOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Emoji explosion
            ForEach(emojis) { emoji in
                Text(emoji.character)
                    .font(.system(size: emoji.size))
                    .offset(x: emoji.x, y: emoji.y)
                    .opacity(emoji.opacity)
                    .rotationEffect(.degrees(emoji.rotation))
            }
            
            VStack(spacing: 40) {
                Spacer()
                
                // 3D rotating heart
                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: "heart.fill")
                            .font(.system(size: 120))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "FF6B6B"),
                                        Color(hex: "FF8787")
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color(hex: "FF6B6B").opacity(0.6), radius: 30, x: 0, y: 15)
                            // .offset(z: CGFloat(index) * -15)
                            .opacity(1 - Double(index) * 0.2)
                    }
                }
                .scaleEffect(titleScale)
                .opacity(titleOpacity)
                
                VStack(spacing: 20) {
                    Text("Welcome to")
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                    
                    // Glowing title
                    Text("MoodDiary")
                        .font(.system(size: 56, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "FFD700")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: .white.opacity(0.5), radius: 20)
                        .shadow(color: Color(hex: "FFD700").opacity(0.5), radius: 30)
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                    
                    Text("Your emotions deserve more than words.\nCapture them in vivid detail.")
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                        .scaleEffect(titleScale)
                        .opacity(titleOpacity)
                }
                
                Spacer()
                Spacer()
            }
        }
        .onAppear {
            generateEmojiExplosion()
            animateContent()
        }
    }
    
    private func generateEmojiExplosion() {
        let emojiList = ["😭", "😢", "😐", "🙂", "😊", "😄", "😍", "🥰", "🎉", "✨", "💫", "⭐️", "🌟", "💖", "💝"]
        
        for i in 0..<30 {
            let emoji = EmojiParticle(
                id: UUID(),
                character: emojiList.randomElement()!,
                x: CGFloat.random(in: -200...200),
                y: CGFloat.random(in: -400...400),
                size: CGFloat.random(in: 30...60),
                opacity: Double.random(in: 0.3...0.8),
                rotation: Double.random(in: -45...45)
            )
            emojis.append(emoji)
            
            // Animate each emoji
            withAnimation(
                .spring(response: 2, dampingFraction: 0.5)
                .delay(Double(i) * 0.02)
            ) {
                if let index = emojis.firstIndex(where: { $0.id == emoji.id }) {
                    emojis[index].x *= 1.5
                    emojis[index].y *= 1.5
                    emojis[index].opacity = 0
                }
            }
        }
    }
    
    private func animateContent() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
            titleScale = 1.0
            titleOpacity = 1.0
        }
    }
}

struct EmojiParticle: Identifiable {
    let id: UUID
    let character: String
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var opacity: Double
    let rotation: Double
}

// MARK: - Enhanced Page 2: Interactive Mood Selector
struct OnboardingPage2_Enhanced: View {
    @State private var selectedMood = 5
    @State private var moodScale: CGFloat = 1.0
    @State private var rippleEffect = false
    @State private var particles: [MoodParticle] = []
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            
            VStack(spacing: 30) {
                Text("Express Yourself")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Tap to feel the emotion")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Interactive 3D Mood Selector
            ZStack {
                // Ripple effect
                if rippleEffect {
                    Circle()
                        .stroke(moodColor.opacity(0.5), lineWidth: 3)
                        .frame(width: 200, height: 200)
                        .scaleEffect(rippleEffect ? 2.0 : 1.0)
                        .opacity(rippleEffect ? 0 : 1)
                }
                
                // Mood particles
                ForEach(particles) { particle in
                    Circle()
                        .fill(moodColor)
                        .frame(width: 8, height: 8)
                        .offset(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
                
                // Main emoji with 3D effect
                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        Text(moodEmoji)
                            .font(.system(size: 140))
                            .shadow(color: moodColor.opacity(0.8), radius: 30, x: 0, y: 20)
                            
                            // .offset(z: CGFloat(index) * -10)
                            .opacity(1 - Double(index) * 0.15)
                    }
                }
                .scaleEffect(moodScale)
                .onTapGesture {
                    animateMoodChange()
                }
            }
            .frame(height: 300)
            
            // Interactive slider with haptics
            MoodSliderView(value: $selectedMood, onChange: {
                animateMoodChange()
            })
            .padding(.horizontal, 40)
            
            Spacer()
            Spacer()
        }
    }
    
    private var moodEmoji: String {
        switch selectedMood {
        case 1: return "😭"
        case 2: return "😢"
        case 3: return "😟"
        case 4: return "😕"
        case 5: return "😐"
        case 6: return "🙂"
        case 7: return "😊"
        case 8: return "😄"
        case 9: return "😁"
        case 10: return "😍"
        default: return "😐"
        }
    }
    
    private var moodColor: Color {
        let colors: [Color] = [
            Color(hex: "8B0000"), Color(hex: "CD5C5C"),
            Color(hex: "FF6B6B"), Color(hex: "FF8C42"),
            Color(hex: "FFB347"), Color(hex: "FFD700"),
            Color(hex: "77DD77"), Color(hex: "50C878"),
            Color(hex: "87CEEB"), Color(hex: "4169E1")
        ]
        return colors[selectedMood - 1]
    }
    
    private func animateMoodChange() {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Scale animation
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            moodScale = 1.3
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.1)) {
            moodScale = 1.0
        }
        
        // Ripple effect
        rippleEffect = false
        withAnimation(.easeOut(duration: 1)) {
            rippleEffect = true
        }
        
        // Generate particles
        generateParticles()
    }
    
    private func generateParticles() {
        particles.removeAll()
        
        for _ in 0..<20 {
            let angle = Double.random(in: 0...(2 * .pi))
            let distance = CGFloat.random(in: 80...150)
            
            let particle = MoodParticle(
                id: UUID(),
                x: cos(angle) * distance,
                y: sin(angle) * distance,
                opacity: 1.0
            )
            particles.append(particle)
            
            withAnimation(.easeOut(duration: 1)) {
                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                    particles[index].opacity = 0
                }
            }
        }
    }
}

struct MoodParticle: Identifiable {
    let id: UUID
    var x: CGFloat
    var y: CGFloat
    var opacity: Double
}

// MARK: - Custom Mood Slider
struct MoodSliderView: View {
    @Binding var value: Int
    let onChange: () -> Void
    @State private var dragLocation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track background
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "8B0000").opacity(0.3),
                                Color(hex: "FFD700").opacity(0.3),
                                Color(hex: "4169E1").opacity(0.3)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 12)
                
                // Progress fill
                Capsule()
                    .fill(currentColor)
                    .frame(width: thumbPosition(in: geometry.size.width), height: 12)
                
                // Thumb
                ZStack {
                    Circle()
                        .fill(currentColor)
                        .frame(width: 40, height: 40)
                        .shadow(color: currentColor.opacity(0.6), radius: 15, x: 0, y: 5)
                    
                    Text("\(value)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .offset(x: thumbPosition(in: geometry.size.width) - 20)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let newValue = Int((gesture.location.x / geometry.size.width) * 9) + 1
                            if newValue != value {
                                value = max(1, min(10, newValue))
                                onChange()
                            }
                        }
                )
            }
        }
        .frame(height: 40)
    }
    
    private func thumbPosition(in width: CGFloat) -> CGFloat {
        return CGFloat(value - 1) / 9 * width
    }
    
    private var currentColor: Color {
        let colors: [Color] = [
            Color(hex: "8B0000"), Color(hex: "CD5C5C"),
            Color(hex: "FF6B6B"), Color(hex: "FF8C42"),
            Color(hex: "FFB347"), Color(hex: "FFD700"),
            Color(hex: "77DD77"), Color(hex: "50C878"),
            Color(hex: "87CEEB"), Color(hex: "4169E1")
        ]
        return colors[value - 1]
    }
}

// MARK: - Enhanced Page 3: Photo Magic
struct OnboardingPage3_Enhanced: View {
    @State private var photos: [PhotoFrame] = []
    @State private var currentPhoto = 0
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Capture the Moment")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Every emotion deserves a photo")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Animated photo carousel
            ZStack {
                ForEach(Array(photos.enumerated()), id: \.element.id) { index, photo in
                    PolaroidFrame(emoji: photo.emoji, color: photo.color)
                        .scaleEffect(scale(for: index))
                        .rotationEffect(.degrees(rotation(for: index)))
                        .offset(y: offset(for: index))
                        .zIndex(zIndex(for: index))
                        .opacity(opacity(for: index))
                }
            }
            .frame(height: 400)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            setupPhotos()
            startCarousel()
        }
    }
    
    private func setupPhotos() {
        let emojis = ["😭", "😐", "🙂", "😊", "😍"]
        let colors = ["#FF6B6B", "#FFB347", "#FFD700", "#77DD77", "#87CEEB"]
        
        for i in 0..<5 {
            photos.append(PhotoFrame(id: i, emoji: emojis[i], color: colors[i]))
        }
    }
    
    private func startCarousel() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                currentPhoto = (currentPhoto + 1) % photos.count
            }
        }
    }
    
    private func scale(for index: Int) -> CGFloat {
        let distance = abs(index - currentPhoto)
        return distance == 0 ? 1.0 : 0.8 - CGFloat(distance) * 0.1
    }
    
    private func rotation(for index: Int) -> Double {
        let distance = Double(index - currentPhoto)
        return distance * 15
    }
    
    private func offset(for index: Int) -> CGFloat {
        let distance = CGFloat(index - currentPhoto)
        return distance * 30
    }
    
    private func zIndex(for index: Int) -> Double {
        return index == currentPhoto ? 10 : Double(5 - abs(index - currentPhoto))
    }
    
    private func opacity(for index: Int) -> Double {
        let distance = abs(index - currentPhoto)
        return distance <= 2 ? 1.0 - Double(distance) * 0.3 : 0
    }
}

struct PhotoFrame: Identifiable {
    let id: Int
    let emoji: String
    let color: String
}

struct PolaroidFrame: View {
    let emoji: String
    let color: String
    
    var body: some View {
        VStack(spacing: 0) {
            // Photo area
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color(hex: color).opacity(0.3))
                
                Text(emoji)
                    .font(.system(size: 100))
            }
            .frame(width: 250, height: 250)
            
            // Bottom white bar
            Rectangle()
                .fill(.white)
                .frame(width: 250, height: 60)
        }
        .background(.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Enhanced Page 4: Final Push
struct OnboardingPage4_Enhanced: View {
    @State private var features: [Feature] = []
    @State private var animateFeatures = false
    
    var body: some View {
        VStack(spacing: 50) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("Everything You Need")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("And so much more")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack(spacing: 20) {
                ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                    FeatureCard(feature: feature)
                        .offset(x: animateFeatures ? 0 : 300)
                        .opacity(animateFeatures ? 1 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1),
                            value: animateFeatures
                        )
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            Spacer()
        }
        .onAppear {
            setupFeatures()
            withAnimation {
                animateFeatures = true
            }
        }
    }
    
    private func setupFeatures() {
        features = [
            Feature(id: 0, icon: "camera.fill", title: "Photo Diary", color: "#FF6B6B"),
            Feature(id: 1, icon: "waveform", title: "Voice Journaling", color: "#4ECDC4"),
            Feature(id: 2, icon: "chart.bar.fill", title: "Smart Insights", color: "#FFD700"),
            Feature(id: 3, icon: "sparkles", title: "AI Powered", color: "#96E6B3")
        ]
    }
}

struct Feature: Identifiable {
    let id: Int
    let icon: String
    let title: String
    let color: String
}

struct FeatureCard: View {
    let feature: Feature
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: feature.icon)
                .font(.system(size: 28))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: feature.color),
                                    Color(hex: feature.color).opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(hex: feature.color).opacity(0.5), radius: 15, x: 0, y: 5)
                )
            
            Text(feature.title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(hex: feature.color))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Custom Page Indicator
struct CustomPageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                    .frame(width: currentPage == index ? 40 : 8, height: 8)
                    .overlay(
                        Capsule()
                            .stroke(Color.white, lineWidth: currentPage == index ? 1 : 0)
                    )
                    .shadow(color: currentPage == index ? .white.opacity(0.5) : .clear, radius: 8)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
    }
}

// MARK: - Morphing Button
struct MorphingButton: View {
    let currentPage: Int
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            ZStack {
                // Background with gradient
                RoundedRectangle(cornerRadius: isPressed ? 25 : 20)
                    .fill(
                        LinearGradient(
                            colors: buttonColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 60)
                    .shadow(color: buttonColors[0].opacity(0.5), radius: 20, x: 0, y: 10)
                
                HStack(spacing: 12) {
                    Text(buttonText)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Image(systemName: buttonIcon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(currentPage == 3 ? 0 : 0))
                }
            }
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    private var buttonText: String {
        currentPage == 3 ? "Get Started" : "Continue"
    }
    
    private var buttonIcon: String {
        currentPage == 3 ? "arrow.right.circle.fill" : "arrow.right"
    }
    
    private var buttonColors: [Color] {
        switch currentPage {
        case 0: return [Color(hex: "667eea"), Color(hex: "764ba2")]
        case 1: return [Color(hex: "f093fb"), Color(hex: "f5576c")]
        case 2: return [Color(hex: "4facfe"), Color(hex: "00f2fe")]
        case 3: return [Color(hex: "43e97b"), Color(hex: "38f9d7")]
        default: return [Color(hex: "667eea"), Color(hex: "764ba2")]
        }
    }
}

#Preview {
    OnboardingView()
}
