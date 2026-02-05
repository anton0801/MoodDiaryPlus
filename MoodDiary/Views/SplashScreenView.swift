import SwiftUI
import Combine

struct SplashScreenView: View {

    @State private var size = 0.5
    @State private var opacity = 0.5
    @State private var rotation = 0.0
    @State private var particlesOpacity = 0.0
    @State private var currentEmojiIndex = 0
    
    @StateObject private var useCase = ApplicationUseCase()
    @State private var eventStreams = Set<AnyCancellable>()
    
    let emojis = ["😭", "😟", "😐", "🙂", "😍"]
    let gradientColors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]
    
    private func setupEventStreams() {
        NotificationCenter.default.publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { useCase.handleAttribution($0) }
            .store(in: &eventStreams)
        
        NotificationCenter.default.publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { useCase.handleDeeplink($0) }
            .store(in: &eventStreams)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "1a1a2e"),
                        Color(hex: "16213e"),
                        Color(hex: "0f3460")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [gradientColors[index % gradientColors.count], .white],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: CGFloat.random(in: 4...12))
                        .offset(x: cos(Double(index) * 18 + rotation) * 120,
                                y: sin(Double(index) * 18 + rotation) * 120)
                        .opacity(particlesOpacity)
                }
                
                VStack(spacing: 20) {
                    // Morphing emoji
                    Text(emojis[currentEmojiIndex])
                        .font(.system(size: 100))
                        .scaleEffect(size)
                        .opacity(opacity)
                        .shadow(color: gradientColors[currentEmojiIndex].opacity(0.6), radius: 30)
                    
                    // App name with shimmer
                    Text("MoodDiary")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(hex: "87CEEB"), .white],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(opacity)
                        .shadow(color: .white.opacity(0.5), radius: 10)
                    
                    Text("Your mood, captured daily")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .opacity(opacity)
                }
                
                NavigationLink(destination: WebContentView()
                    .navigationBarBackButtonHidden(true), isActive: $useCase.shouldNavigateToWeb) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: RootView().navigationBarBackButtonHidden(true),
                    isActive: $useCase.shouldNavigateToMain
                ) {
                    EmptyView()
                }
            }
            .onAppear {
                setupEventStreams()
                
                // Animate particles rotation
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
                
                // Fade in particles
                withAnimation(.easeIn(duration: 1)) {
                    particlesOpacity = 1.0
                }
                
                // Emoji morph sequence
                Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
                    if currentEmojiIndex < emojis.count - 1 {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentEmojiIndex += 1
                        }
                    } else {
                        timer.invalidate()
                    }
                }
                
                // Scale and fade in
                withAnimation(.easeInOut(duration: 1.2)) {
                    size = 1.0
                    opacity = 1.0
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $useCase.shouldShowPermissionPrompt) {
            AlertPromptView(useCase: useCase)
        }
        .fullScreenCover(isPresented: $useCase.shouldShowOffline) {
            UnavailableView()
        }
    }
}

#Preview {
    SplashScreenView()
}

struct UnavailableView: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(geo.size.width > geo.size.height ? "internet_issue_background_second" : "internet_issue_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .ignoresSafeArea()
                
                Image("internet_issue_alert")
                    .resizable()
                    .frame(width: 300, height: 270)
            }
        }
        .ignoresSafeArea()
    }
}
