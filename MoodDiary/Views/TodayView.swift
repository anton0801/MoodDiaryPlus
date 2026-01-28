
import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TodayViewModel()
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        viewModel.moodColor.opacity(0.3),
                        Color(hex: "1a1a2e").opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Date header
                        dateHeader
                        
                        // Mood selector
                        moodSelector
                        
                        // Photo section
                        photoSection
                        
                        // Note section
                        noteSection
                        
                        // Activities section
                        activitiesSection
                        
                        // Save button
                        saveButton
                    }
                    .padding()
                }
                
                // Confetti overlay
                if viewModel.showSaveConfetti {
                    ConfettiView()
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(image: $viewModel.selectedPhoto, sourceType: .photoLibrary)
                    .onDisappear {
                        viewModel.updateCanSave()
                    }
            }
            .sheet(isPresented: $viewModel.showCamera) {
                ImagePicker(image: $viewModel.selectedPhoto, sourceType: .camera)
                    .onDisappear {
                        viewModel.updateCanSave()
                    }
            }
            .sheet(isPresented: $viewModel.showFilterEditor) {
                if let photo = viewModel.selectedPhoto {
                    PhotoFilterView(image: photo) { edited in
                        viewModel.selectedPhoto = edited
                        viewModel.updateCanSave()
                    }
                }
            }
            .onAppear {
                viewModel.requestSpeechAuthorization()
            }
        }
    }
    
    private var dateHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().formatted(date: .complete, time: .omitted))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("How are you feeling?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
    
    private var moodSelector: some View {
        VStack(spacing: 20) {
            Text(viewModel.moodEmoji)
                .font(.system(size: 100))
                .shadow(color: viewModel.moodColor.opacity(0.5), radius: 20)
            
            VStack(spacing: 12) {
                HStack {
                    Text("😭")
                    Spacer()
                    Text("😐")
                    Spacer()
                    Text("😍")
                }
                .font(.system(size: 20))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 10)
                
                Slider(value: Binding(
                    get: { Double(viewModel.currentMoodScore) },
                    set: { viewModel.currentMoodScore = Int($0) }
                ), in: 1...10, step: 1)
                .accentColor(viewModel.moodColor)
                
                Text("Mood: \(viewModel.currentMoodScore)/10")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(viewModel.moodColor.opacity(0.5), lineWidth: 2)
                )
        )
    }
    
    private var photoSection: some View {
        VStack(spacing: 15) {
            HStack {
                Text("Photo of the Day")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("*Required")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.red.opacity(0.8))
            }
            
            if let photo = viewModel.selectedPhoto {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 300, maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(viewModel.moodColor, lineWidth: 4)
                        )
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            viewModel.showFilterEditor = true
                        }) {
                            Image(systemName: "camera.filters")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                        
                        Button(action: {
                            withAnimation {
                                viewModel.selectedPhoto = nil
                                viewModel.updateCanSave()
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                    }
                    .padding(10)
                }
            } else {
                VStack(spacing: 15) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Add a photo to capture your mood!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            viewModel.showCamera = true
                        }) {
                            Label("Camera", systemImage: "camera")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    LinearGradient(
                                        colors: [viewModel.moodColor, viewModel.moodColor.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Button(action: {
                            viewModel.showImagePicker = true
                        }) {
                            Label("Library", systemImage: "photo")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                )
                        }
                    }
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                                .foregroundColor(.white.opacity(0.3))
                        )
                )
            }
        }
    }
    
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("How are you feeling?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    if viewModel.isRecording {
                        viewModel.stopRecording()
                    } else {
                        viewModel.startRecording()
                    }
                }) {
                    Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(viewModel.isRecording ? .red : viewModel.moodColor)
                        .symbolEffect(.pulse, isActive: viewModel.isRecording)
                }
            }
            
            TextEditor(text: $viewModel.currentNote)
                .frame(height: 150)
                .scrollContentBackground(.hidden)
                .padding(15)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
                .foregroundColor(.white)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .overlay(
                    Group {
                        if viewModel.currentNote.isEmpty {
                            Text("Write your thoughts or use the mic...")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 16, design: .rounded))
                                .padding(.leading, 20)
                                .padding(.top, 23)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )
        }
    }
    
    private var activitiesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Activities")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(viewModel.activities) { activity in
                    ActivityButton(
                        activity: activity,
                        isSelected: viewModel.selectedActivities.contains(activity.name)
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            viewModel.toggleActivity(activity.name)
                        }
                    }
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                viewModel.saveEntry(modelContext: modelContext)
            }
        }) {
            Text("Save Entry")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Group {
                        if viewModel.canSave {
                            LinearGradient(
                                colors: [viewModel.moodColor, viewModel.moodColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.gray.opacity(0.3)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: viewModel.canSave ? viewModel.moodColor.opacity(0.4) : .clear, radius: 15, y: 5)
        }
        .disabled(!viewModel.canSave)
        .scaleEffect(viewModel.canSave ? 1.0 : 0.95)
        .animation(.spring(response: 0.3), value: viewModel.canSave)
    }
}

// Supporting Views
struct ActivityButton: View {
    let activity: Activity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: activity.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color(hex: activity.color))
                
                Text(activity.name)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: activity.color) : Color.white.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: activity.color).opacity(0.5), lineWidth: isSelected ? 2 : 0)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
