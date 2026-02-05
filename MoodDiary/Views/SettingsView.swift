import SwiftUI
import LocalAuthentication
import StoreKit

struct SettingsView: View {
    @AppStorage("isPremium") private var isPremium = false
    @AppStorage("hasEnabledNotifications") private var hasEnabledNotifications = false
    @AppStorage("notificationHour") private var notificationHour = 21
    @AppStorage("notificationMinute") private var notificationMinute = 0
    @AppStorage("requiresAuthentication") private var requiresAuthentication = false
    @AppStorage("selectedThemeMode") private var selectedThemeMode = "auto"
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    
    @State private var showPremiumSheet = false
    @State private var showNotificationAlert = false
    @State private var showAuthError = false
    
    @Environment(\.requestReview) var review
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: themeColor).opacity(0.2),
                        Color(hex: "1a1a2e").opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
//                        // Premium section
//                        if !isPremium {
//                            premiumBanner
//                        }
//                        
                        // Account section
//                        settingsSection(title: "Account") {
//                            if isPremium {
//                                settingsRow(
//                                    icon: "crown.fill",
//                                    title: "Premium Active",
//                                    subtitle: "Thank you for your support!",
//                                    iconColor: "#FFD700"
//                                )
//                            } else {
//                                settingsButton(
//                                    icon: "crown.fill",
//                                    title: "Upgrade to Premium",
//                                    iconColor: "#FFD700"
//                                ) {
//                                    showPremiumSheet = true
//                                }
//                            }
//                        }
                        
                        // Notifications section
                        settingsSection(title: "Notifications") {
                            Toggle(isOn: $hasEnabledNotifications) {
                                HStack(spacing: 12) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "#FF6B6B"))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(Color(hex: "#FF6B6B").opacity(0.2))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Daily Reminders")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Text("Get notified to log your mood")
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                            }
                            .tint(Color(hex: themeColor))
                            .onChange(of: hasEnabledNotifications) { newValue in
                                if newValue {
                                    requestNotificationPermission()
                                } else {
                                    NotificationManager.shared.cancelAllNotifications()
                                }
                            }
                            
                            if hasEnabledNotifications {
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "#4ECDC4"))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(Color(hex: "#4ECDC4").opacity(0.2))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Reminder Time")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Text(String(format: "%02d:%02d", notificationHour, notificationMinute))
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    DatePicker(
                                        "",
                                        selection: Binding(
                                            get: {
                                                var components = DateComponents()
                                                components.hour = notificationHour
                                                components.minute = notificationMinute
                                                return Calendar.current.date(from: components) ?? Date()
                                            },
                                            set: { newDate in
                                                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                                                notificationHour = components.hour ?? 21
                                                notificationMinute = components.minute ?? 0
                                                NotificationManager.shared.scheduleDailyNotification(hour: notificationHour, minute: notificationMinute)
                                            }
                                        ),
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                    .colorScheme(.dark)
                                }
                            }
                        }
                        
                        // Security section
                        settingsSection(title: "Security") {
                            Toggle(isOn: $requiresAuthentication) {
                                HStack(spacing: 12) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color(hex: "#9B59B6"))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(Color(hex: "#9B59B6").opacity(0.2))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("App Lock")
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Text("Require Face ID or passcode")
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                }
                            }
                            .tint(Color(hex: themeColor))
                            .onChange(of: requiresAuthentication) { newValue in
                                if newValue {
                                    authenticateUser()
                                }
                            }
                        }
                        
                        // Appearance section
                        settingsSection(title: "Appearance") {
                            VStack(spacing: 15) {
                                ForEach(["auto", "light", "dark", "manual"], id: \.self) { mode in
                                    Button(action: {
                                        selectedThemeMode = mode
                                    }) {
                                        HStack {
                                            Image(systemName: themeIcon(for: mode))
                                                .font(.system(size: 20))
                                                .foregroundColor(Color(hex: themeColor))
                                                .frame(width: 40, height: 40)
                                                .background(
                                                    Circle()
                                                        .fill(Color(hex: themeColor).opacity(0.2))
                                                )
                                            
                                            Text(mode.capitalized)
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundColor(.white)
                                            
                                            Spacer()
                                            
                                            if selectedThemeMode == mode {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color(hex: themeColor))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
//                        // Data section
//                        settingsSection(title: "Data") {
//                            settingsButton(
//                                icon: "square.and.arrow.up.fill",
//                                title: "Export Data",
//                                iconColor: "#3498DB"
//                            ) {
//                                // Export functionality
//                            }
//                            
//                            settingsButton(
//                                icon: "trash.fill",
//                                title: "Clear All Data",
//                                iconColor: "#E74C3C"
//                            ) {
//                                // Clear data functionality
//                            }
//                        }
                        
                        // About section
                        settingsSection(title: "About") {
                            settingsRow(
                                icon: "info.circle.fill",
                                title: "Version",
                                subtitle: "1.0.0",
                                iconColor: "#95A5A6"
                            )
                            
                            settingsButton(
                                icon: "star.fill",
                                title: "Rate MoodDiary",
                                iconColor: "#F39C12"
                            ) {
                                review()
                            }
                            
//                            settingsButton(
//                                icon: "envelope.fill",
//                                title: "Contact Support",
//                                iconColor: "#16A085"
//                            ) {
//                                // Contact support functionality
//                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showPremiumSheet) {
                PremiumView()
            }
            .alert("Authentication Failed", isPresented: $showAuthError) {
                Button("OK", role: .cancel) {
                    requiresAuthentication = false
                }
            } message: {
                Text("Could not authenticate using Face ID or Touch ID")
            }
        }
    }
    
    private var premiumBanner: some View {
        Button(action: {
            showPremiumSheet = true
        }) {
            VStack(spacing: 15) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.yellow)
                
                Text("Upgrade to Premium")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Unlimited habits • Advanced themes • Ad-free • Full export • iCloud sync")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text("Start Free Trial")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.yellow)
                    )
            }
            .frame(maxWidth: .infinity)
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#FFD700").opacity(0.3), Color(hex: "#FFA500").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
                    )
            )
        }
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 5)
            
            VStack(spacing: 12) {
                content()
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    private func settingsRow(icon: String, title: String, subtitle: String, iconColor: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: iconColor))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color(hex: iconColor).opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
        }
    }
    
    private func settingsButton(icon: String, title: String, iconColor: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: iconColor))
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color(hex: iconColor).opacity(0.2))
                    )
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
    
    private func themeIcon(for mode: String) -> String {
        switch mode {
        case "auto": return "sparkles"
        case "light": return "sun.max.fill"
        case "dark": return "moon.fill"
        case "manual": return "paintbrush.fill"
        default: return "sparkles"
        }
    }
    
    private func requestNotificationPermission() {
        NotificationManager.shared.requestAuthorization { granted in
            if granted {
                NotificationManager.shared.scheduleDailyNotification(hour: notificationHour, minute: notificationMinute)
            } else {
                hasEnabledNotifications = false
                showNotificationAlert = true
            }
        }
    }
    
    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to enable app lock"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if !success {
                        showAuthError = true
                    }
                }
            }
        } else {
            showAuthError = true
        }
    }
}

struct AlertPromptView: View {
    @ObservedObject var useCase: ApplicationUseCase
    @State private var pulse = false
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                Image(g.size.width > g.size.height ? "notification_bg_second" : "notifications_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea()
                    .opacity(0.9)
                
                if g.size.width < g.size.height {
                    VStack(spacing: 12) {
                        Spacer()
                        
                        Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                            .font(.custom("PassionOne-Bold", size: 24))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .multilineTextAlignment(.center)
                        
                        Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
                            .font(.custom("PassionOne-Bold", size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 12)
                            .multilineTextAlignment(.center)
                        
                        actionControls
                    }
                    .padding(.bottom, 24)
                } else {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading, spacing: 12) {
                            Spacer()
                            
                            Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                                .font(.custom("PassionOne-Bold", size: 24))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .multilineTextAlignment(.leading)
                            
                            Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
                                .font(.custom("PassionOne-Bold", size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.horizontal, 12)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            actionControls
                        }
                        Spacer()
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        
    }
    
    private var messageContent: some View {
        VStack(spacing: 30) {
            Text("Stay Balanced").font(.largeTitle.bold())
            Text("Enable alerts to receive growth insights and balance reminders")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 68)
        }
    }
    
    @State var animateButton = false
    
    private var actionControls: some View {
        VStack(spacing: 30) {
            Button {
                useCase.grantPermission()
            } label: {
                Image("notifications_button")
                    .resizable()
                    .frame(width: 300, height: 55)
            }
            
            Button { useCase.skipPermission() } label: {
                Text("Skip")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 60)
    }
}


struct PremiumView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPremium") private var isPremium = false
    @AppStorage("currentThemeColor") private var themeColor = "#4ECDC4"
    
    let features = [
        ("infinity", "Unlimited Habits", "Track as many habits as you want"),
        ("paintpalette.fill", "Advanced Themes", "Custom gradients and colors"),
        ("xmark.rectangle.fill", "Ad-Free Experience", "No interruptions"),
        ("doc.text.fill", "Full Export", "Export all your data anytime"),
        ("icloud.fill", "iCloud Sync", "Access your data on all devices")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(hex: "#FFD700").opacity(0.3),
                        Color(hex: "1a1a2e").opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Crown icon
                        Image(systemName: "crown.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.yellow)
                            .shadow(color: .yellow.opacity(0.5), radius: 20)
                        
                        VStack(spacing: 10) {
                            Text("MoodDiary Premium")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Unlock the full potential")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        // Features
                        VStack(spacing: 15) {
                            ForEach(features, id: \.0) { icon, title, description in
                                HStack(spacing: 15) {
                                    Image(systemName: icon)
                                        .font(.system(size: 24))
                                        .foregroundColor(.yellow)
                                        .frame(width: 50, height: 50)
                                        .background(
                                            Circle()
                                                .fill(.yellow.opacity(0.2))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(title)
                                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                                            .foregroundColor(.white)
                                        
                                        Text(description)
                                            .font(.system(size: 13, design: .rounded))
                                            .foregroundColor(.white.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                }
                                .padding(15)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                )
                            }
                        }
                        
                        // Pricing
                        VStack(spacing: 15) {
                            Text("$4.99 / month")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("7-day free trial • Cancel anytime")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 10)
                        
                        // Subscribe button
                        Button(action: {
                            // Simulate subscription
                            isPremium = true
                            dismiss()
                        }) {
                            Text("Start Free Trial")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [.yellow, Color(hex: "#FFA500")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .shadow(color: .yellow.opacity(0.5), radius: 15, y: 5)
                        }
                        
                        Text("By subscribing, you agree to our Terms of Service and Privacy Policy")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}
