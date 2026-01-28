import SwiftUI
import SwiftData
import Speech
import AVFoundation

@MainActor
class TodayViewModel: ObservableObject {
    @Published var currentMoodScore: Int = 5
    @Published var currentNote: String = ""
    @Published var selectedActivities: Set<String> = []
    @Published var selectedPhoto: UIImage?
    @Published var isRecording: Bool = false
    @Published var showImagePicker: Bool = false
    @Published var showCamera: Bool = false
    @Published var showFilterEditor: Bool = false
    @Published var canSave: Bool = false
    @Published var showSaveConfetti: Bool = false
    
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let activities = [
        Activity(name: "Sleep", icon: "bed.double.fill", color: "#9B59B6"),
        Activity(name: "Workout", icon: "figure.run", color: "#E74C3C"),
        Activity(name: "Coffee", icon: "cup.and.saucer.fill", color: "#8B4513"),
        Activity(name: "Friends", icon: "person.2.fill", color: "#3498DB"),
        Activity(name: "Work", icon: "briefcase.fill", color: "#34495E"),
        Activity(name: "Walk", icon: "figure.walk", color: "#27AE60"),
        Activity(name: "Food", icon: "fork.knife", color: "#F39C12"),
        Activity(name: "Reading", icon: "book.fill", color: "#16A085"),
        Activity(name: "Music", icon: "music.note", color: "#E91E63"),
        Activity(name: "Gaming", icon: "gamecontroller.fill", color: "#9C27B0"),
        Activity(name: "Meditation", icon: "figure.mind.and.body", color: "#00BCD4"),
        Activity(name: "Movie", icon: "film.fill", color: "#FF5722")
    ]
    
    var moodEmoji: String {
        switch currentMoodScore {
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
    
    var moodColor: Color {
        let colors: [Color] = [
            Color(hex: "8B0000"), // 1
            Color(hex: "CD5C5C"), // 2
            Color(hex: "FF6B6B"), // 3
            Color(hex: "FF8C42"), // 4
            Color(hex: "FFB347"), // 5
            Color(hex: "FFD700"), // 6
            Color(hex: "77DD77"), // 7
            Color(hex: "50C878"), // 8
            Color(hex: "87CEEB"), // 9
            Color(hex: "4169E1")  // 10
        ]
        return colors[currentMoodScore - 1]
    }
    
    func toggleActivity(_ activity: String) {
        if selectedActivities.contains(activity) {
            selectedActivities.remove(activity)
        } else {
            selectedActivities.insert(activity)
        }
    }
    
    func updateCanSave() {
        canSave = selectedPhoto != nil
    }
    
    func saveEntry(modelContext: ModelContext) {
        guard let photoData = selectedPhoto?.jpegData(compressionQuality: 0.8) else { return }
        
        let entry = MoodEntry(
            date: Date(),
            moodScore: currentMoodScore,
            moodEmoji: moodEmoji,
            photoData: photoData,
            note: currentNote,
            selectedActivities: Array(selectedActivities),
            colorTheme: moodColor.toHex() ?? "#4ECDC4"
        )
        
        modelContext.insert(entry)
        
        // Update theme
        UserDefaults.standard.set(entry.colorTheme, forKey: "currentThemeColor")
        UserDefaults.standard.set(Date(), forKey: "lastThemeUpdate")
        
        // Show confetti
        showSaveConfetti = true
        
        // Reset form
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.resetForm()
        }
    }
    
    func resetForm() {
        currentMoodScore = 5
        currentNote = ""
        selectedActivities.removeAll()
        selectedPhoto = nil
        showSaveConfetti = false
        canSave = false
    }
    
    // MARK: - Speech Recognition
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                default:
                    print("Speech recognition not authorized")
                }
            }
        }
    }
    
    func startRecording() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            return
        }
        
        do {
            // Cancel previous task
            recognitionTask?.cancel()
            recognitionTask = nil
            
            // Configure audio session
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Create recognition request
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else { return }
            recognitionRequest.shouldReportPartialResults = true
            
            let inputNode = audioEngine.inputNode
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    DispatchQueue.main.async {
                        self.currentNote = result.bestTranscription.formattedString
                    }
                }
                
                if error != nil || result?.isFinal == true {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    DispatchQueue.main.async {
                        self.isRecording = false
                    }
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                recognitionRequest.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isRecording = true
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isRecording = false
    }
}

struct Activity: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String
}
