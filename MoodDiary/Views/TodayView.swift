//
//import SwiftUI
//import SwiftData
//
//struct TodayView: View {
//    @Environment(\.modelContext) private var modelContext
//    @StateObject private var viewModel = TodayViewModel()
//    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
//    
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                // Background gradient
//                LinearGradient(
//                    colors: [
//                        viewModel.moodColor.opacity(0.3),
//                        Color(hex: "1a1a2e").opacity(0.95)
//                    ],
//                    startPoint: .top,
//                    endPoint: .bottom
//                )
//                .ignoresSafeArea()
//                
//                ScrollView {
//                    VStack(spacing: 25) {
//                        // Date header
//                        dateHeader
//                        
//                        // Mood selector
//                        moodSelector
//                        
//                        // Photo section
//                        photoSection
//                        
//                        // Note section
//                        noteSection
//                        
//                        // Activities section
//                        activitiesSection
//                        
//                        // Save button
//                        saveButton
//                    }
//                    .padding()
//                }
//                
//                // Confetti overlay
//                if viewModel.showSaveConfetti {
//                    ConfettiView()
//                        .ignoresSafeArea()
//                        .allowsHitTesting(false)
//                }
//            }
//            .navigationTitle("Today")
//            .navigationBarTitleDisplayMode(.large)
//            .sheet(isPresented: $viewModel.showImagePicker) {
//                ImagePicker(image: $viewModel.selectedPhoto, sourceType: .photoLibrary)
//                    .onDisappear {
//                        viewModel.updateCanSave()
//                    }
//            }
//            .sheet(isPresented: $viewModel.showCamera) {
//                ImagePicker(image: $viewModel.selectedPhoto, sourceType: .camera)
//                    .onDisappear {
//                        viewModel.updateCanSave()
//                    }
//            }
//            .sheet(isPresented: $viewModel.showFilterEditor) {
//                if let photo = viewModel.selectedPhoto {
//                    PhotoFilterView(image: photo) { edited in
//                        viewModel.selectedPhoto = edited
//                        viewModel.updateCanSave()
//                    }
//                }
//            }
//            .onAppear {
//                viewModel.requestSpeechAuthorization()
//            }
//        }
//    }
//    
//    private var dateHeader: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 4) {
//                Text(Date().formatted(date: .complete, time: .omitted))
//                    .font(.system(size: 16, weight: .medium, design: .rounded))
//                    .foregroundColor(.white.opacity(0.7))
//                
//                Text("How are you feeling?")
//                    .font(.system(size: 28, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//            }
//            
//            Spacer()
//        }
//    }
//    
//    private var moodSelector: some View {
//        VStack(spacing: 20) {
//            Text(viewModel.moodEmoji)
//                .font(.system(size: 100))
//                .shadow(color: viewModel.moodColor.opacity(0.5), radius: 20)
//            
//            VStack(spacing: 12) {
//                HStack {
//                    Text("😭")
//                    Spacer()
//                    Text("😐")
//                    Spacer()
//                    Text("😍")
//                }
//                .font(.system(size: 20))
//                .foregroundColor(.white.opacity(0.6))
//                .padding(.horizontal, 10)
//                
//                Slider(value: Binding(
//                    get: { Double(viewModel.currentMoodScore) },
//                    set: { viewModel.currentMoodScore = Int($0) }
//                ), in: 1...10, step: 1)
//                .accentColor(viewModel.moodColor)
//                
//                Text("Mood: \(viewModel.currentMoodScore)/10")
//                    .font(.system(size: 16, weight: .semibold, design: .rounded))
//                    .foregroundColor(.white)
//            }
//        }
//        .padding(25)
//        .background(
//            RoundedRectangle(cornerRadius: 24)
//                .fill(.ultraThinMaterial)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(viewModel.moodColor.opacity(0.5), lineWidth: 2)
//                )
//        )
//    }
//    
//    private var photoSection: some View {
//        VStack(spacing: 15) {
//            HStack {
//                Text("Photo of the Day")
//                    .font(.system(size: 20, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//                
//                Spacer()
//                
//                Text("*Required")
//                    .font(.system(size: 12, weight: .medium, design: .rounded))
//                    .foregroundColor(.red.opacity(0.8))
//            }
//            
//            if let photo = viewModel.selectedPhoto {
//                ZStack(alignment: .topTrailing) {
//                    Image(uiImage: photo)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(maxWidth: 300, maxHeight: 300)
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 20)
//                                .stroke(viewModel.moodColor, lineWidth: 4)
//                        )
//                    
//                    HStack(spacing: 12) {
//                        Button(action: {
//                            viewModel.showFilterEditor = true
//                        }) {
//                            Image(systemName: "camera.filters")
//                                .font(.system(size: 18))
//                                .foregroundColor(.white)
//                                .frame(width: 40, height: 40)
//                                .background(Circle().fill(.ultraThinMaterial))
//                        }
//                        
//                        Button(action: {
//                            withAnimation {
//                                viewModel.selectedPhoto = nil
//                                viewModel.updateCanSave()
//                            }
//                        }) {
//                            Image(systemName: "xmark")
//                                .font(.system(size: 18))
//                                .foregroundColor(.white)
//                                .frame(width: 40, height: 40)
//                                .background(Circle().fill(.ultraThinMaterial))
//                        }
//                    }
//                    .padding(10)
//                }
//            } else {
//                VStack(spacing: 15) {
//                    Image(systemName: "camera.fill")
//                        .font(.system(size: 50))
//                        .foregroundColor(.white.opacity(0.5))
//                    
//                    Text("Add a photo to capture your mood!")
//                        .font(.system(size: 16, weight: .medium, design: .rounded))
//                        .foregroundColor(.white.opacity(0.7))
//                        .multilineTextAlignment(.center)
//                    
//                    HStack(spacing: 15) {
//                        Button(action: {
//                            viewModel.showCamera = true
//                        }) {
//                            Label("Camera", systemImage: "camera")
//                                .font(.system(size: 16, weight: .semibold, design: .rounded))
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 50)
//                                .background(
//                                    LinearGradient(
//                                        colors: [viewModel.moodColor, viewModel.moodColor.opacity(0.7)],
//                                        startPoint: .leading,
//                                        endPoint: .trailing
//                                    )
//                                )
//                                .clipShape(RoundedRectangle(cornerRadius: 12))
//                        }
//                        
//                        Button(action: {
//                            viewModel.showImagePicker = true
//                        }) {
//                            Label("Library", systemImage: "photo")
//                                .font(.system(size: 16, weight: .semibold, design: .rounded))
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 50)
//                                .background(
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .fill(.ultraThinMaterial)
//                                )
//                        }
//                    }
//                }
//                .frame(height: 300)
//                .frame(maxWidth: .infinity)
//                .background(
//                    RoundedRectangle(cornerRadius: 20)
//                        .fill(.ultraThinMaterial)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 20)
//                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
//                                .foregroundColor(.white.opacity(0.3))
//                        )
//                )
//            }
//        }
//    }
//    
//    private var noteSection: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            HStack {
//                Text("How are you feeling?")
//                    .font(.system(size: 20, weight: .bold, design: .rounded))
//                    .foregroundColor(.white)
//                
//                Spacer()
//                
//                Button(action: {
//                    if viewModel.isRecording {
//                        viewModel.stopRecording()
//                    } else {
//                        viewModel.startRecording()
//                    }
//                }) {
//                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
//                        .font(.system(size: 28))
//                        .foregroundColor(viewModel.isRecording ? .red : viewModel.moodColor)
//                        .symbolEffect(.pulse, isActive: viewModel.isRecording)
//                }
//            }
//            
//            TextEditor(text: $viewModel.currentNote)
//                .frame(height: 150)
//                .scrollContentBackground(.hidden)
//                .padding(15)
//                .background(
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(.ultraThinMaterial)
//                )
//                .foregroundColor(.white)
//                .font(.system(size: 16, weight: .regular, design: .rounded))
//                .overlay(
//                    Group {
//                        if viewModel.currentNote.isEmpty {
//                            Text("Write your thoughts or use the mic...")
//                                .foregroundColor(.white.opacity(0.5))
//                                .font(.system(size: 16, design: .rounded))
//                                .padding(.leading, 20)
//                                .padding(.top, 23)
//                                .allowsHitTesting(false)
//                        }
//                    },
//                    alignment: .topLeading
//                )
//        }
//    }
//    
//    private var activitiesSection: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            Text("Activities")
//                .font(.system(size: 20, weight: .bold, design: .rounded))
//                .foregroundColor(.white)
//            
//            LazyVGrid(columns: [
//                GridItem(.flexible()),
//                GridItem(.flexible()),
//                GridItem(.flexible()),
//                GridItem(.flexible())
//            ], spacing: 12) {
//                ForEach(viewModel.activities) { activity in
//                    ActivityButton(
//                        activity: activity,
//                        isSelected: viewModel.selectedActivities.contains(activity.name)
//                    ) {
//                        withAnimation(.spring(response: 0.3)) {
//                            viewModel.toggleActivity(activity.name)
//                        }
//                    }
//                }
//            }
//        }
//    }
//    
//    private var saveButton: some View {
//        Button(action: {
//            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
//                viewModel.saveEntry(modelContext: modelContext)
//            }
//        }) {
//            Text("Save Entry")
//                .font(.system(size: 18, weight: .bold, design: .rounded))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .frame(height: 56)
//                .background(
//                    Group {
//                        if viewModel.canSave {
//                            LinearGradient(
//                                colors: [viewModel.moodColor, viewModel.moodColor.opacity(0.7)],
//                                startPoint: .leading,
//                                endPoint: .trailing
//                            )
//                        } else {
//                            Color.gray.opacity(0.3)
//                        }
//                    }
//                )
//                .clipShape(RoundedRectangle(cornerRadius: 16))
//                .shadow(color: viewModel.canSave ? viewModel.moodColor.opacity(0.4) : .clear, radius: 15, y: 5)
//        }
//        .disabled(!viewModel.canSave)
//        .scaleEffect(viewModel.canSave ? 1.0 : 0.95)
//        .animation(.spring(response: 0.3), value: viewModel.canSave)
//    }
//}
//
//// Supporting Views
//struct ActivityButton: View {
//    let activity: Activity
//    let isSelected: Bool
//    let action: () -> Void
//    
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: 8) {
//                Image(systemName: activity.icon)
//                    .font(.system(size: 24))
//                    .foregroundColor(isSelected ? .white : Color(hex: activity.color))
//                
//                Text(activity.name)
//                    .font(.system(size: 11, weight: .medium, design: .rounded))
//                    .foregroundColor(.white)
//                    .lineLimit(1)
//                    .minimumScaleFactor(0.8)
//            }
//            .frame(maxWidth: .infinity)
//            .frame(height: 70)
//            .background(
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(isSelected ? Color(hex: activity.color) : Color.white.opacity(0.3))
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color(hex: activity.color).opacity(0.5), lineWidth: isSelected ? 2 : 0)
//            )
//        }
//        .buttonStyle(ScaleButtonStyle())
//    }
//}
//
//struct ScaleButtonStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
//            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
//    }
//}

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TodayViewModel()
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    
    @State private var showParallaxEffect = false
    @State private var headerOffset: CGFloat = 0
    @State private var cardScale: CGFloat = 0.9
    @State private var cardOpacity: Double = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated 3D background with parallax
                Parallax3DBackground(offset: headerOffset, themeColor: themeColor)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Floating date header
                        FloatingDateHeader()
                            .padding(.top, 20)
                        
                        // 3D Mood selector with physics
                        MoodSelector3D(viewModel: viewModel)
                            .scaleEffect(cardScale)
                            .opacity(cardOpacity)
                        
                        // Holographic photo section
                        HolographicPhotoSection(viewModel: viewModel)
                            .scaleEffect(cardScale)
                            .opacity(cardOpacity)
                        
                        // AI-powered note section
                        AIPoweredNoteSection(viewModel: viewModel)
                            .scaleEffect(cardScale)
                            .opacity(cardOpacity)
                        
                        // Interactive activities grid
                        InteractiveActivitiesGrid(viewModel: viewModel)
                            .scaleEffect(cardScale)
                            .opacity(cardOpacity)
                        
                        // Morphing save button
                        MorphingSaveButton(viewModel: viewModel, modelContext: modelContext)
                            .scaleEffect(cardScale)
                            .opacity(cardOpacity)
                    }
                    .padding(.horizontal)
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll")).minY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    headerOffset = value
                }
                
                // Floating confetti
                if viewModel.showSaveConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
                
                // Success animation overlay
                if viewModel.showSaveConfetti {
                    SuccessAnimationOverlay()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(Color(hex: themeColor))
                        Text("Today")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    StreakButton()
                }
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(image: $viewModel.selectedPhoto, sourceType: .photoLibrary)
                    .onDisappear {
                        viewModel.updateCanSave()
                    }
            }
            .sheet(isPresented: $viewModel.showCamera) {
                EnhancedCameraView(image: $viewModel.selectedPhoto)
                    .onDisappear {
                        viewModel.updateCanSave()
                    }
            }
            .sheet(isPresented: $viewModel.showFilterEditor) {
                if let photo = viewModel.selectedPhoto {
                    EnhancedPhotoFilterView(image: photo) { edited in
                        viewModel.selectedPhoto = edited
                        viewModel.updateCanSave()
                    }
                }
            }
            .onAppear {
                animateEntrance()
                viewModel.requestSpeechAuthorization()
            }
        }
    }
    
    private func animateEntrance() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }
    }
}

// MARK: - Parallax 3D Background
struct Parallax3DBackground: View {
    let offset: CGFloat
    let themeColor: String
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: themeColor).opacity(0.4),
                    Color(hex: "0F2027"),
                    Color(hex: "203A43"),
                    Color(hex: "2C5364")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating 3D shapes with parallax
            GeometryReader { geometry in
                ForEach(0..<8, id: \.self) { index in
                    FloatingShape(
                        index: index,
                        offset: offset,
                        size: geometry.size,
                        rotation: rotation,
                        color: Color(hex: themeColor)
                    )
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct FloatingShape: View {
    let index: Int
    let offset: CGFloat
    let size: CGSize
    let rotation: Double
    let color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(
                RadialGradient(
                    colors: [
                        color.opacity(0.3),
                        color.opacity(0.05)
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 100
                )
            )
            .frame(width: 150, height: 150)
            .blur(radius: 30)
            .rotationEffect(.degrees(rotation + Double(index * 45)))
            .offset(
                x: cos(Double(index) * 0.8) * CGFloat(size.width) * 0.4 + offset * CGFloat(index) * 0.05,
                y: sin(Double(index) * 0.8) * CGFloat(size.height) * 0.4 + offset * CGFloat(index) * 0.08
            )
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Floating Date Header
struct FloatingDateHeader: View {
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Animated calendar icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF6B6B").opacity(0.3),
                                    Color(hex: "FF6B6B").opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    VStack(spacing: 2) {
                        Text(Date().formatted(.dateTime.day()))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(Date().formatted(.dateTime.month(.abbreviated)).uppercased())
                            .font(.system(size: 8, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .shadow(color: Color(hex: "FF6B6B").opacity(0.3), radius: 15, x: 0, y: 5)
                .scaleEffect(animate ? 1.1 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animate)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date().formatted(.dateTime.weekday(.wide)))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("How are you feeling today?")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            animate = true
        }
    }
}

// MARK: - 3D Mood Selector
struct MoodSelector3D: View {
    @ObservedObject var viewModel: TodayViewModel
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var particlesActive = false
    
    var body: some View {
        VStack(spacing: 25) {
            // 3D rotating emoji with depth
            ZStack {
                // Glow effect
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                viewModel.moodColor.opacity(0.6),
                                viewModel.moodColor.opacity(0.2),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 20)
                    .scaleEffect(pulseScale)
                
                // Mood particles
                if particlesActive {
                    ForEach(0..<12, id: \.self) { index in
                        Circle()
                            .fill(viewModel.moodColor)
                            .frame(width: 8, height: 8)
                            .offset(
                                x: cos(Double(index) * .pi / 6) * 100,
                                y: sin(Double(index) * .pi / 6) * 100
                            )
                            .opacity(0.6)
                    }
                }
                
                // 3D layered emoji
                ForEach(0..<5, id: \.self) { layer in
                    Text(viewModel.moodEmoji)
                        .font(.system(size: 120))
                        .shadow(
                            color: viewModel.moodColor.opacity(0.8),
                            radius: 30,
                            x: 0,
                            y: CGFloat(layer) * 5
                        )
                        // .offset(z: CGFloat(layer) * -8)
                        .opacity(1.0 - Double(layer) * 0.12)
                        .blur(radius: CGFloat(layer) * 0.5)
                }
            }
            .rotation3DEffect(
                .degrees(rotationAngle),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.5
            )
            .onTapGesture {
                animateMoodChange()
            }
            
            // Interactive mood slider with haptics
            VStack(spacing: 15) {
                HStack {
                    Text("😭")
                        .font(.system(size: 24))
                    
                    Spacer()
                    
                    Text(viewModel.moodEmoji)
                        .font(.system(size: 28))
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("😍")
                        .font(.system(size: 24))
                }
                .foregroundColor(.white.opacity(0.8))
                
                // Custom 3D slider
                Interactive3DSlider(
                    value: $viewModel.currentMoodScore,
                    color: viewModel.moodColor
                ) {
                    animateMoodChange()
                }
                
                // Mood labels
                HStack {
                    Text(moodLabel)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("\(viewModel.currentMoodScore)/10")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(viewModel.moodColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(viewModel.moodColor.opacity(0.2))
                        )
                }
            }
        }
        .padding(30)
        .background(
            ZStack {
                // Glassmorphic background
                RoundedRectangle(cornerRadius: 30)
                    .fill(.ultraThinMaterial)
                
                // Border gradient
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        LinearGradient(
                            colors: [
                                viewModel.moodColor.opacity(0.6),
                                viewModel.moodColor.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            }
        )
        .shadow(color: viewModel.moodColor.opacity(0.3), radius: 30, x: 0, y: 15)
        .onAppear {
            startPulseAnimation()
        }
    }
    
    private var moodLabel: String {
        switch viewModel.currentMoodScore {
        case 1...2: return "Terrible"
        case 3...4: return "Bad"
        case 5...6: return "Okay"
        case 7...8: return "Good"
        case 9...10: return "Amazing"
        default: return "Neutral"
        }
    }
    
    private func animateMoodChange() {
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        
        // Rotation animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            rotationAngle += 360
        }
        
        // Particles
        particlesActive = true
        withAnimation(.easeOut(duration: 1)) {
            particlesActive = false
        }
    }
    
    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
    }
}

// MARK: - Interactive 3D Slider
struct Interactive3DSlider: View {
    @Binding var value: Int
    let color: Color
    let onChange: () -> Void
    
    @State private var dragLocation: CGFloat = 0
    @State private var isPressed = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track with gradient
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "8B0000").opacity(0.2),
                                Color(hex: "FFD700").opacity(0.2),
                                Color(hex: "4169E1").opacity(0.2)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 16)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                
                // Active progress with shimmer
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: thumbPosition(in: geometry.size.width), height: 16)
                    .shadow(color: color.opacity(0.6), radius: 10, x: 0, y: 3)
                
                // Thumb with 3D effect
                ZStack {
                    // Shadow layers
                    ForEach(0..<3, id: \.self) { layer in
                        Circle()
                            .fill(color)
                            .frame(width: 50, height: 50)
                            .offset(y: CGFloat(layer) * 2)
                            .opacity(0.3 - Double(layer) * 0.1)
                    }
                    
                    // Main thumb
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [color.opacity(0.8), color],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 30
                                )
                            )
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 50, height: 50)
                        
                        Text("\(value)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .shadow(color: color.opacity(0.8), radius: 20, x: 0, y: 8)
                    .scaleEffect(isPressed ? 1.15 : 1.0)
                }
                .offset(x: thumbPosition(in: geometry.size.width) - 25)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            isPressed = true
                            let newValue = Int((gesture.location.x / geometry.size.width) * 9) + 1
                            if newValue != value {
                                value = max(1, min(10, newValue))
                                onChange()
                            }
                        }
                        .onEnded { _ in
                            isPressed = false
                        }
                )
            }
        }
        .frame(height: 50)
    }
    
    private func thumbPosition(in width: CGFloat) -> CGFloat {
        return CGFloat(value - 1) / 9 * width
    }
}

// MARK: - Holographic Photo Section
struct HolographicPhotoSection: View {
    @ObservedObject var viewModel: TodayViewModel
    @State private var hologramOffset: CGFloat = 0
    @State private var shimmerOffset: CGFloat = -300
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Photo of the Day")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                if viewModel.selectedPhoto == nil {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text("Required")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.red.opacity(0.9))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.red.opacity(0.2))
                    )
                }
            }
            
            if let photo = viewModel.selectedPhoto {
                // Photo with holographic effect
                ZStack(alignment: .topTrailing) {
                    // Holographic border animation
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FF6B6B"),
                                    Color(hex: "4ECDC4"),
                                    Color(hex: "FFD700"),
                                    Color(hex: "FF6B6B")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 4
                        )
                        .frame(height: 350)
                        .hueRotation(.degrees(hologramOffset))
                    
                    // Photo
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 350)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        .overlay(
                            // Shimmer effect
                            Rectangle()
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
                                .rotationEffect(.degrees(45))
                                .offset(x: shimmerOffset)
                                .mask(
                                    RoundedRectangle(cornerRadius: 25)
                                )
                        )
                    
                    // Action buttons
                    HStack(spacing: 12) {
                        PhotoActionButton(
                            icon: "camera.filters",
                            color: Color(hex: "4ECDC4")
                        ) {
                            viewModel.showFilterEditor = true
                        }
                        
                        PhotoActionButton(
                            icon: "arrow.triangle.2.circlepath",
                            color: Color(hex: "FFD700")
                        ) {
                            // Retake photo
                            viewModel.showCamera = true
                        }
                        
                        PhotoActionButton(
                            icon: "xmark",
                            color: Color(hex: "FF6B6B")
                        ) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                viewModel.selectedPhoto = nil
                                viewModel.updateCanSave()
                            }
                        }
                    }
                    .padding(15)
                }
                .shadow(color: viewModel.moodColor.opacity(0.4), radius: 30, x: 0, y: 15)
            } else {
                // Empty state with animated gradient
                VStack(spacing: 20) {
                    ZStack {
                        // Animated gradient circle
                        Circle()
                            .fill(
                                AngularGradient(
                                    colors: [
                                        Color(hex: "FF6B6B"),
                                        Color(hex: "4ECDC4"),
                                        Color(hex: "FFD700"),
                                        Color(hex: "FF6B6B")
                                    ],
                                    center: .center
                                )
                            )
                            .frame(width: 100, height: 100)
                            .blur(radius: 20)
                            .hueRotation(.degrees(hologramOffset))
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                    }
                    
                    Text("Capture your mood visually")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Every photo tells a story")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(spacing: 15) {
                        PhotoCaptureButton(
                            icon: "camera.fill",
                            title: "Camera",
                            gradient: [Color(hex: "FF6B6B"), Color(hex: "FF8787")]
                        ) {
                            viewModel.showCamera = true
                        }
                        
                        PhotoCaptureButton(
                            icon: "photo.fill",
                            title: "Library",
                            gradient: [Color(hex: "4ECDC4"), Color(hex: "45B7D1")]
                        ) {
                            viewModel.showImagePicker = true
                        }
                    }
                }
                .frame(height: 350)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .strokeBorder(
                                    style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                                )
                                .foregroundColor(.white.opacity(0.3))
                        )
                )
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .onAppear {
            startHologramAnimation()
            startShimmerAnimation()
        }
    }
    
    private func startHologramAnimation() {
        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
            hologramOffset = 360
        }
    }
    
    private func startShimmerAnimation() {
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            shimmerOffset = 600
        }
    }
}

struct PhotoActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    ZStack {
                        Circle()
                            .fill(color)
                        
                        Circle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.5)
                    }
                )
                .shadow(color: color.opacity(0.6), radius: 10, x: 0, y: 5)
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

struct PhotoCaptureButton: View {
    let icon: String
    let title: String
    let gradient: [Color]
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                LinearGradient(
                    colors: gradient,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: gradient[0].opacity(0.5), radius: 15, x: 0, y: 8)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - AI-Powered Note Section
struct AIPoweredNoteSection: View {
    @ObservedObject var viewModel: TodayViewModel
    @State private var aiSuggestions: [String] = []
    @State private var showSuggestions = false
    @State private var typingAnimation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color(hex: "FFD700"))
                    
                    Text("Your Thoughts")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Voice button with animation
                VoiceRecordButton(viewModel: viewModel)
            }
            
            // AI Suggestions (if available)
            if showSuggestions && !aiSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(Color(hex: "FFD700"))
                        Text("AI Suggestions")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(aiSuggestions, id: \.self) { suggestion in
                                SuggestionChip(text: suggestion) {
                                    viewModel.currentNote = suggestion
                                    showSuggestions = false
                                }
                            }
                        }
                    }
                }
            }
            
            // Text editor with gradient border
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.currentNote)
                    .frame(height: 180)
                    .scrollContentBackground(.hidden)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "4ECDC4").opacity(0.5),
                                        Color(hex: "45B7D1").opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                
                if viewModel.currentNote.isEmpty {
                    Text(viewModel.isRecording ? "Listening..." : "Share your thoughts or use voice...")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 16, design: .rounded))
                        .padding(.leading, 25)
                        .padding(.top, 28)
                        .allowsHitTesting(false)
                }
                
                // Typing indicator
                if typingAnimation && !viewModel.currentNote.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .fill(Color(hex: "4ECDC4"))
                                .frame(width: 6, height: 6)
                                .scaleEffect(typingAnimation ? 1.0 : 0.5)
                                .animation(
                                    .easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                    value: typingAnimation
                                )
                        }
                    }
                    .padding(8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .offset(x: 20, y: 160)
                }
            }
            
            // Word count and AI analyze button
            HStack {
                Text("\(viewModel.currentNote.count) characters")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                
                Spacer()
                
                if !viewModel.currentNote.isEmpty {
                    Button(action: generateAISuggestions) {
                        HStack(spacing: 6) {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 12))
                            Text("AI Enhance")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color(hex: "FFD700"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color(hex: "FFD700").opacity(0.2))
                        )
                    }
                }
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .onChange(of: viewModel.currentNote) { _, _ in
            if !viewModel.currentNote.isEmpty {
                typingAnimation = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    typingAnimation = false
                }
            }
        }
    }
    
    private func generateAISuggestions() {
        // Simulate AI suggestions based on mood
        let moodScore = viewModel.currentMoodScore
        
        if moodScore <= 3 {
            aiSuggestions = [
                "Remember, tough times don't last forever ✨",
                "It's okay to feel this way. You're human 💙",
                "Tomorrow is a new opportunity 🌅"
            ]
        } else if moodScore <= 6 {
            aiSuggestions = [
                "Keep pushing forward, you're doing great! 💪",
                "Small steps lead to big changes 🌟",
                "Balance is key in life 🧘‍♀️"
            ]
        } else {
            aiSuggestions = [
                "Your positive energy is contagious! ✨",
                "Celebrate these moments of joy! 🎉",
                "You're radiating happiness today! 😊"
            ]
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showSuggestions = true
        }
    }
}

struct VoiceRecordButton: View {
    @ObservedObject var viewModel: TodayViewModel
    @State private var pulseAnimation = false
    
    var body: some View {
        Button(action: {
            if viewModel.isRecording {
                viewModel.stopRecording()
            } else {
                viewModel.startRecording()
            }
        }) {
            ZStack {
                // Pulse effect when recording
                if viewModel.isRecording {
                    Circle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                        .opacity(pulseAnimation ? 0 : 1)
                }
                
                Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(viewModel.isRecording ? .red : Color(hex: "4ECDC4"))
                    .symbolEffect(.pulse, isActive: viewModel.isRecording)
            }
        }
        .onChange(of: viewModel.isRecording) { _, isRecording in
            if isRecording {
                withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: false)) {
                    pulseAnimation = true
                }
            } else {
                pulseAnimation = false
            }
        }
    }
}

struct SuggestionChip: View {
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "FFD700").opacity(0.3),
                                    Color(hex: "FFA500").opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "FFD700").opacity(0.5), lineWidth: 1)
                        )
                )
        }
    }
}

