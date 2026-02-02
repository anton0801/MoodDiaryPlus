import AppsFlyerLib
import Firebase
import FirebaseMessaging
import Foundation
import WebKit

protocol NetworkGateway {
    func fetchAttribution(deviceID: String) async throws -> [String: Any]
    func fetchEndpoint(attribution: [String: Any]) async throws -> String
}

final class HTTPNetworkGateway: NetworkGateway {
    
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 90
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        
        self.session = URLSession(configuration: config)
    }
    
    func fetchAttribution(deviceID: String) async throws -> [String: Any] {
        let baseURL = "https://gcdsdk.appsflyer.com/install_data/v4.0"
        let appID = "id\(AppConfiguration.appID)"
        
        var components = URLComponents(string: "\(baseURL)/\(appID)")
        components?.queryItems = [
            URLQueryItem(name: "devkey", value: AppConfiguration.devKey),
            URLQueryItem(name: "device_id", value: deviceID)
        ]
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkError.decodingError
        }
        
        return json
    }
    
    private var userAgent: String = WKWebView().value(forKey: "userAgent") as? String ?? ""
    
    func fetchEndpoint(attribution: [String: Any]) async throws -> String {
        guard let url = URL(string: "https://mooddiaryplus.com/config.php") else {
            throw NetworkError.invalidURL
        }
        
        var payload: [String: Any] = attribution
        payload["os"] = "iOS"
        payload["af_id"] = AppsFlyerLib.shared().getAppsFlyerUID()
        payload["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        payload["firebase_project_id"] = FirebaseApp.app()?.options.gcmSenderID
        payload["store_id"] = "id\(AppConfiguration.appID)"
        payload["push_token"] = UserDefaults.standard.string(forKey: "push_token") ?? Messaging.messaging().fcmToken
        payload["locale"] = Locale.preferredLanguages.first?.prefix(2).uppercased() ?? "EN"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        var lastError: Error?
        let delays: [Double] = [3.5, 7.0, 14.0]
        
        for (index, delay) in delays.enumerated() {
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.serverError
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let success = json["ok"] as? Bool,
                          success,
                          let endpoint = json["url"] as? String else {
                        throw NetworkError.decodingError
                    }
                    
                    return endpoint
                } else if httpResponse.statusCode == 429 {
                    let backoff = delay * Double(index + 1)
                    try await Task.sleep(nanoseconds: UInt64(backoff * 1_000_000_000))
                    continue
                } else {
                    throw NetworkError.serverError
                }
            } catch {
                lastError = error
                if index < delays.count - 1 {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        throw lastError ?? NetworkError.serverError
    }
}
