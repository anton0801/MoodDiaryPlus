import Foundation
import AppsFlyerLib
import AppTrackingTransparency

final class TrackingOrchestrator: NSObject, AppsFlyerLibDelegate, DeepLinkDelegate {
    private var orchestrator: MarketingOrchestrator
    
    init(orchestrator: MarketingOrchestrator) {
        self.orchestrator = orchestrator
    }
    
    func setup() {
        let sdk = AppsFlyerLib.shared()
        sdk.appsFlyerDevKey = AppConfiguration.devKey
        sdk.appleAppID = AppConfiguration.appID
        sdk.delegate = self
        sdk.deepLinkDelegate = self
        sdk.isDebug = false
    }
    
    func initiate() {
        if #available(iOS 14.0, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                    UserDefaults.standard.set(status.rawValue, forKey: "tracking_state")
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "tracking_moment")
                }
            }
        } else {
            AppsFlyerLib.shared().start()
        }
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        orchestrator.receive(marketing: data)
    }
    
    func onConversionDataFail(_ error: Error) {
        var errorData: [AnyHashable: Any] = [:]
        errorData["error"] = true
        errorData["error_info"] = error.localizedDescription
        orchestrator.receive(marketing: errorData)
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard case .found = result.status, let deepLink = result.deepLink else { return }
        orchestrator.receive(navigation: deepLink.clickEvent)
    }
}
