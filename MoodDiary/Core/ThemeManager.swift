import SwiftUI

struct DeeplinkModel {
    let data: [String: Any]
    
    var isEmpty: Bool { data.isEmpty }
    
    static var empty: DeeplinkModel {
        DeeplinkModel(data: [:])
    }
}

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: ThemeColor = .auto
    
    enum ThemeColor {
        case auto
        case light
        case dark
        case custom(String)
        
        var colorScheme: ColorScheme? {
            switch self {
            case .light: return .light
            case .dark: return .dark
            default: return nil
            }
        }
    }
    
    private init() {}
    
    func updateThemeFromMood(moodScore: Int) {
        let colors: [String] = [
            "#8B0000", "#CD5C5C", "#FF6B6B", "#FF8C42",
            "#FFB347", "#FFD700", "#77DD77", "#50C878",
            "#87CEEB", "#4169E1"
        ]
        
        let colorIndex = min(max(moodScore - 1, 0), 9)
        UserDefaults.standard.set(colors[colorIndex], forKey: "currentThemeColor")
        UserDefaults.standard.set(Date(), forKey: "lastThemeUpdate")
    }
    
    func shouldUpdateTheme() -> Bool {
        guard let lastUpdate = UserDefaults.standard.object(forKey: "lastThemeUpdate") as? Date else {
            return true
        }
        
        let hoursSinceUpdate = Calendar.current.dateComponents([.hour], from: lastUpdate, to: Date()).hour ?? 0
        return hoursSinceUpdate >= 24
    }
    
    func getThemeColor(for moodScore: Int) -> String {
        let colors: [String] = [
            "#8B0000", "#CD5C5C", "#FF6B6B", "#FF8C42",
            "#FFB347", "#FFD700", "#77DD77", "#50C878",
            "#87CEEB", "#4169E1"
        ]
        
        let colorIndex = min(max(moodScore - 1, 0), 9)
        return colors[colorIndex]
    }
}
