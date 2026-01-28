import SwiftUI
import LocalAuthentication

struct AuthenticationView: View {
    @Binding var isUnlocked: Bool
    @State private var showError = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("MoodDiary is Locked")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Authenticate to continue")
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                
                Button(action: authenticate) {
                    HStack {
                        Image(systemName: "faceid")
                            .font(.system(size: 24))
                        
                        Text("Unlock")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(width: 200, height: 56)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "#4ECDC4"), Color(hex: "#45B7D1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .onAppear {
            authenticate()
        }
        .alert("Authentication Failed", isPresented: $showError) {
            Button("Try Again") {
                authenticate()
            }
        }
    }
    
    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Unlock MoodDiary"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        withAnimation {
                            isUnlocked = true
                        }
                    } else {
                        showError = true
                    }
                }
            }
        } else {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock MoodDiary") { success, error in
                DispatchQueue.main.async {
                    if success {
                        withAnimation {
                            isUnlocked = true
                        }
                    } else {
                        showError = true
                    }
                }
            }
        }
    }
}
