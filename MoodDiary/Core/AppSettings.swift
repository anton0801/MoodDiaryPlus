import Foundation

struct AppSettings: Codable {
    var isPremium: Bool = false
    var hasEnabledNotifications: Bool = false
    var notificationTime: Date = Calendar.current.date(from: DateComponents(hour: 21, minute: 0)) ?? Date()
    var requiresAuthentication: Bool = false
    var selectedThemeMode: ThemeMode = .auto
    var manualThemeColor: String = "#4ECDC4"
    
    enum ThemeMode: String, Codable {
        case auto
        case light
        case dark
        case manual
    }
}
