import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        if hasCompletedOnboarding {
            ContentView()
        } else {
            ZStack {
                // Dynamic background based on page
                backgroundGradient(for: currentPage)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                TabView(selection: $currentPage) {
                    OnboardingPage1()
                        .tag(0)
                    OnboardingPage2()
                        .tag(1)
                    OnboardingPage3()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                VStack {
                    Spacer()
                    
                    // Custom page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.white : Color.white.opacity(0.3))
                                .frame(width: currentPage == index ? 30 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Action button
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                currentPage += 1
                            }
                        } else {
                            withAnimation {
                                hasCompletedOnboarding = true
                            }
                        }
                    }) {
                        Text(currentPage == 2 ? "Get Started" : "Next")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "FF6B6B"), Color(hex: "4ECDC4")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
        }
    }
     
    func backgroundGradient(for page: Int) -> LinearGradient {
        let colors: [[Color]] = [
            [Color(hex: "667eea"), Color(hex: "764ba2")],
            [Color(hex: "f093fb"), Color(hex: "f5576c")],
            [Color(hex: "4facfe"), Color(hex: "00f2fe")]
        ]
        return LinearGradient(colors: colors[page], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

// MARK: - Page 1: Welcome
struct OnboardingPage1: View {
    @State private var floatingOffset: [CGFloat] = Array(repeating: 0, count: 8)
    
    let emojis = ["😭", "😢", "😐", "🙂", "😊", "😄", "😍", "🥰"]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Floating emoji cloud
            ZStack {
                ForEach(0..<emojis.count, id: \.self) { index in
                    Text(emojis[index])
                        .font(.system(size: 50))
                        .offset(
                            x: cos(Double(index) * 45) * 80,
                            y: sin(Double(index) * 45) * 80 + floatingOffset[index]
                        )
                        .shadow(color: .white.opacity(0.3), radius: 10)
                }
            }
            .frame(height: 300)
            .onAppear {
                for index in 0..<emojis.count {
                    withAnimation(
                        .easeInOut(duration: Double.random(in: 2...3))
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1)
                    ) {
                        floatingOffset[index] = CGFloat.random(in: -20...20)
                    }
                }
            }
            
            VStack(spacing: 16) {
                Text("Welcome to")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                
                Text("MoodDiary")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 5)
                
                Text("Capture your emotions with a photo every day and watch your mood patterns unfold")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
            
            Spacer()
            Spacer()
        }
    }
}

// MARK: - Page 2: Features
struct OnboardingPage2: View {
    @State private var selectedMood = 5
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Interactive mood preview
            VStack(spacing: 30) {
                Text("Your Mood, Your Colors")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // Mood selector preview
                VStack(spacing: 20) {
                    Text(moodEmoji(for: selectedMood))
                        .font(.system(size: 100))
                        .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3), value: pulseAnimation)
                    
                    HStack(spacing: 12) {
                        ForEach(1..<11) { mood in
                            Circle()
                                .fill(selectedMood == mood ? Color.white : Color.white.opacity(0.3))
                                .frame(width: selectedMood == mood ? 16 : 10, height: selectedMood == mood ? 16 : 10)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedMood = mood
                                        pulseAnimation.toggle()
                                    }
                                }
                        }
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.1), radius: 20)
                )
                
                Text("The app's theme automatically adapts to your mood, creating a personalized emotional atmosphere")
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
            Spacer()
        }
    }
    
    func moodEmoji(for score: Int) -> String {
        switch score {
        case 1...2: return "😭"
        case 3...4: return "😟"
        case 5...6: return "😐"
        case 7...8: return "🙂"
        default: return "😍"
        }
    }
}

// MARK: - Page 3: Permissions
struct OnboardingPage3: View {
    @State private var cameraIconRotation = 0.0
    @State private var micIconScale = 1.0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                Text("We'll Need")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                VStack(spacing: 30) {
                    // Camera permission
                    HStack(spacing: 20) {
        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(cameraIconRotation))
                            .frame(width: 70, height: 70)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Camera Access")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("To capture your daily photo")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                    
                    // Microphone permission
                    HStack(spacing: 20) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .scaleEffect(micIconScale)
                            .frame(width: 70, height: 70)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Microphone Access")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("For voice journaling")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer()
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
                }
                .padding(.horizontal, 30)
                
                Text("Your privacy is important. All data stays on your device")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
            }
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                cameraIconRotation = 10
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                micIconScale = 1.2
            }
        }
    }
}
