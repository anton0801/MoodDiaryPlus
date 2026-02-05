import Foundation
import Combine
import UIKit
import UserNotifications
import Network
import AppsFlyerLib

@MainActor
final class ApplicationUseCase: ObservableObject {
    
    // MARK: - Published State
    @Published private(set) var flowState: FlowState = .empty
    @Published var shouldShowPermissionPrompt: Bool = false
    @Published var shouldShowOffline: Bool = false
    @Published var shouldNavigateToMain: Bool = false
    @Published var shouldNavigateToWeb: Bool = false
    
    // MARK: - Gateways
    private let storage: StorageGateway
    private let validation: ValidationGateway
    private let network: NetworkGateway
    
    // MARK: - Models
    private var attribution: AttributionModel = .empty
    private var deeplink: DeeplinkModel = .empty
    private var permission: PermissionModel = .initial
    private var launchConfig: LaunchConfig = .initial
    
    // MARK: - Control
    private var timeoutTask: Task<Void, Never>?
    private var isProcessing = false
    
    private let networkMonitor = NWPathMonitor()
    
    // MARK: - Initialization
    init(
        storage: StorageGateway = FileStorageGateway(),
        validation: ValidationGateway = FirebaseValidationGateway(),
        network: NetworkGateway = HTTPNetworkGateway()
    ) {
        self.storage = storage
        self.validation = validation
        self.network = network
        
        loadSavedState()
        watchNetwork()
        beginFlow()
    }
    
    // MARK: - Public Actions
    
    func handleAttribution(_ data: [String: Any]) {
        attribution = AttributionModel(data: data)
        storage.saveAttribution(attribution)
        
        Task {
            await runValidation()
        }
    }
    
    func handleDeeplink(_ data: [String: Any]) {
        deeplink = DeeplinkModel(data: data)
        storage.saveDeeplink(deeplink)
    }
    
    func grantPermission() {
        requestAuthorization { [weak self] granted in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                self.permission = PermissionModel(
                    status: granted ? .granted : .denied,
                    lastAsked: Date()
                )
                
                self.storage.savePermission(self.permission)
                
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                self.shouldShowPermissionPrompt = false
                self.shouldNavigateToWeb = true
            }
        }
    }
    
    func skipPermission() {
        permission = PermissionModel(
            status: .notDetermined,
            lastAsked: Date()
        )
        
        storage.savePermission(permission)
        shouldShowPermissionPrompt = false
        self.shouldNavigateToWeb = true
    }
    
    private func loadSavedState() {
        attribution = storage.loadAttribution()
        deeplink = storage.loadDeeplink()
        permission = storage.loadPermission()
        
        launchConfig = LaunchConfig(
            isFirstLaunch: storage.isFirstLaunch(),
            savedEndpoint: storage.loadEndpoint(),
            operationMode: storage.loadMode()
        )
    }
    
    private func beginFlow() {
        updateFlow(.preparing)
        startTimeout()
    }
    
    private func startTimeout() {
        timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            
            guard !isProcessing else { return }
            
            await MainActor.run {
                self.updateFlow(.waiting)
                self.shouldNavigateToMain = true
            }
        }
    }
    
    private func watchNetwork() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self = self, !self.isProcessing else { return }
                
                if path.status == .satisfied {
                    self.shouldShowOffline = false
                } else {
                    self.shouldShowOffline = true
                }
            }
        }
        networkMonitor.start(queue: .global(qos: .background))
    }
    
    private func runValidation() async {
        guard flowState.endpoint == nil else { return }
        
        updateFlow(.checking)
        
        do {
            let isValid = try await validation.validate()
            
            if isValid {
                updateFlow(.verified)
                await executeBusinessLogic()
            } else {
                updateFlow(.waiting)
                shouldNavigateToMain = true
            }
        } catch {
            updateFlow(.waiting)
            shouldNavigateToMain = true
        }
    }
    
    private func executeBusinessLogic() async {
        guard !attribution.isEmpty else {
            loadSavedEndpoint()
            return
        }
        
        if let temp = UserDefaults.standard.string(forKey: "temp_url") {
            finalize(endpoint: temp)
            return
        }
        
        if needsOrganicFlow() {
            await handleOrganicFlow()
            return
        }
        
        await requestEndpoint()
    }
    
    private func needsOrganicFlow() -> Bool {
        launchConfig.isFirstLaunch && attribution.isOrganic
    }
    
    private func handleOrganicFlow() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        do {
            let deviceID = AppsFlyerLib.shared().getAppsFlyerUID()
            let fetched = try await network.fetchAttribution(deviceID: deviceID)
            
            var merged = fetched
            for (key, value) in deeplink.data {
                if merged[key] == nil {
                    merged[key] = value
                }
            }
            
            attribution = AttributionModel(data: merged)
            storage.saveAttribution(attribution)
            
            await requestEndpoint()
        } catch {
            updateFlow(.waiting)
            shouldNavigateToMain = true
        }
    }
    
    private func requestEndpoint() async {
        do {
            let endpoint = try await network.fetchEndpoint(attribution: attribution.data)
            
            storage.saveEndpoint(endpoint)
            storage.saveMode("Active")
            storage.markLaunchCompleted()
            
            launchConfig = LaunchConfig(
                isFirstLaunch: false,
                savedEndpoint: endpoint,
                operationMode: "Active"
            )
            
            finalize(endpoint: endpoint)
        } catch {
            loadSavedEndpoint()
        }
    }
    
    private func loadSavedEndpoint() {
        if let saved = launchConfig.savedEndpoint {
            finalize(endpoint: saved)
        } else {
            updateFlow(.waiting)
            shouldNavigateToMain = true
        }
    }
    
    private func finalize(endpoint: String) {
        guard !isProcessing else { return }
        
        timeoutTask?.cancel()
        isProcessing = true
        
        updateFlow(.running(url: endpoint))
        
        if permission.canAsk {
            shouldShowPermissionPrompt = true
        } else {
            shouldNavigateToWeb = true
        }
    }
    
    private func updateFlow(_ phase: FlowState.FlowPhase) {
        var newState = flowState
        newState.current = phase
        
        if case .running(let url) = phase {
            newState.endpoint = url
            newState.isReady = true
        }
        
        flowState = newState
    }
    
    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { granted, _ in
            completion(granted)
        }
    }
}
