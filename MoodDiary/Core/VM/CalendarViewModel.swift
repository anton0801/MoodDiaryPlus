import SwiftUI
import SwiftData
import Foundation
import FirebaseDatabase
import AppsFlyerLib
import FirebaseCore
import FirebaseMessaging
import CommonCrypto
import WebKit

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var selectedEntry: MoodEntry?
    @Published var showEntryDetail: Bool = false
    @Published var currentMonth: Date = Date()
    
    func fetchEntries(for date: Date, modelContext: ModelContext) -> [MoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching entries: \(error)")
            return []
        }
    }
    
    func fetchAllEntries(modelContext: ModelContext) -> [MoodEntry] {
        let descriptor = FetchDescriptor<MoodEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching all entries: \(error)")
            return []
        }
    }
}


protocol StorageGateway {
    func saveAttribution(_ model: AttributionModel)
    func loadAttribution() -> AttributionModel
    func saveDeeplink(_ model: DeeplinkModel)
    func loadDeeplink() -> DeeplinkModel
    func saveEndpoint(_ url: String)
    func loadEndpoint() -> String?
    func saveMode(_ mode: String)
    func loadMode() -> String?
    func markLaunchCompleted()
    func isFirstLaunch() -> Bool
    func savePermission(_ model: PermissionModel)
    func loadPermission() -> PermissionModel
}

final class FileStorageGateway: StorageGateway {
    
    private let store = UserDefaults(suiteName: "group.mooddiary.storage")!
    private let backup = UserDefaults.standard
    private var cache: [String: Any] = [:]
    
    // UNIQUE: Keys with md_ prefix
    private enum Keys {
        static let attribution = "md_attribution_data"
        static let deeplink = "md_deeplink_data"
        static let endpoint = "md_endpoint_url"
        static let mode = "md_operation_mode"
        static let launch = "md_first_launch"
        static let permission = "md_permission_state"
        static let permissionDate = "md_permission_date"
    }
    
    init() {
        loadCache()
    }
    
    func saveAttribution(_ model: AttributionModel) {
        if let json = serialize(model.data) {
            store.set(json, forKey: Keys.attribution)
            cache[Keys.attribution] = json
        }
    }
    
    func loadAttribution() -> AttributionModel {
        if let json = cache[Keys.attribution] as? String ?? store.string(forKey: Keys.attribution),
           let data = deserialize(json) {
            return AttributionModel(data: data)
        }
        return .empty
    }
    
    func saveDeeplink(_ model: DeeplinkModel) {
        if let json = serialize(model.data) {
            let encoded = encodeBase64(json)
            store.set(encoded, forKey: Keys.deeplink)
        }
    }
    
    func loadDeeplink() -> DeeplinkModel {
        if let encoded = store.string(forKey: Keys.deeplink),
           let json = decodeBase64(encoded),
           let data = deserialize(json) {
            return DeeplinkModel(data: data)
        }
        return .empty
    }
    
    func saveEndpoint(_ url: String) {
        store.set(url, forKey: Keys.endpoint)
        backup.set(url, forKey: Keys.endpoint)
        cache[Keys.endpoint] = url
    }
    
    func loadEndpoint() -> String? {
        cache[Keys.endpoint] as? String ?? store.string(forKey: Keys.endpoint) ?? backup.string(forKey: Keys.endpoint)
    }
    
    func saveMode(_ mode: String) {
        store.set(mode, forKey: Keys.mode)
    }
    
    func loadMode() -> String? {
        store.string(forKey: Keys.mode)
    }
    
    func markLaunchCompleted() {
        store.set(true, forKey: Keys.launch)
    }
    
    func isFirstLaunch() -> Bool {
        !store.bool(forKey: Keys.launch)
    }
    
    func savePermission(_ model: PermissionModel) {
        let statusValue: Int
        switch model.status {
        case .notDetermined: statusValue = 0
        case .granted: statusValue = 1
        case .denied: statusValue = 2
        }
        
        store.set(statusValue, forKey: Keys.permission)
        
        if let date = model.lastAsked {
            store.set(date.timeIntervalSince1970 * 1000, forKey: Keys.permissionDate)
        }
    }
    
    func loadPermission() -> PermissionModel {
        let statusValue = store.integer(forKey: Keys.permission)
        let status: PermissionModel.PermissionStatus
        
        switch statusValue {
        case 1: status = .granted
        case 2: status = .denied
        default: status = .notDetermined
        }
        
        let timestamp = store.double(forKey: Keys.permissionDate)
        let date = timestamp > 0 ? Date(timeIntervalSince1970: timestamp / 1000) : nil
        
        return PermissionModel(status: status, lastAsked: date)
    }
    
    private func loadCache() {
        if let endpoint = store.string(forKey: Keys.endpoint) {
            cache[Keys.endpoint] = endpoint
        }
    }
    
    private func serialize(_ data: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let string = String(data: jsonData, encoding: .utf8) else { return nil }
        return string
    }
    
    private func deserialize(_ string: String) -> [String: Any]? {
        guard let data = string.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return dict
    }
    
    private func encodeBase64(_ string: String) -> String {
        Data(string.utf8).base64EncodedString()
            .replacingOccurrences(of: "=", with: "&")
            .replacingOccurrences(of: "+", with: "$")
    }
    
    private func decodeBase64(_ string: String) -> String? {
        let base64 = string
            .replacingOccurrences(of: "&", with: "=")
            .replacingOccurrences(of: "$", with: "+")
        
        guard let data = Data(base64Encoded: base64),
              let string = String(data: data, encoding: .utf8) else { return nil }
        return string
    }
}

enum NetworkError: Error {
    case invalidURL
    case serverError
    case decodingError
}

struct AppConfiguration {
    static let appID = "6758392311"
    static let devKey = "V4HwUT2zR4SHG6HViS7ccQ"
}
