import Foundation 
import Combine
import KeyboardShortcuts


class SettingsModel: ObservableObject {
    @Published var fileURL: URL?
    @Published var previewLines: Int = 20
    @Published var previewWidth: Int = 400
    @Published var topLeft = true
    @Published var topRight = false
    @Published var bottomLeft = false
    @Published var bottomRight = false
    @Published var openOnClick: Bool = true
    @Published var launchAtLogin: Bool = false {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            toggleLaunchAtLogin(launchAtLogin)
        }
    }
    // Enable recording and handling of the shortcut
    @Published var shortcutEnabled: Bool = false {
        didSet {
            UserDefaults.standard.set(shortcutEnabled, forKey: "shortcutEnabled")
        }
    }
    // Corner used when toggling via shortcut
    @Published var shortcutCorner: Corner = .bottomRight {
        didSet {
            UserDefaults.standard.set(shortcutCorner.rawValue, forKey: "shortcutCorner")
        }
    }
    
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSettings()
        let plistExists = FileManager.default.fileExists(atPath: LaunchAgentHelper.plistPath)
        launchAtLogin = plistExists
        objectWillChange
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveSettings()
            }
        .store(in: &cancellables)}
    
    private func toggleLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try LaunchAgentHelper.enable()
            } else {
                try LaunchAgentHelper.disable()
            }
        } catch {
            print("[SettingsModel] Failed to toggle launchAtLogin:", error)
        }
    }
    
    func loadSettings() {
        let defaults = UserDefaults.standard
        let pl = defaults.integer(forKey: "previewLines")
        previewLines = pl == 0 ? 20 : pl

        let pw = defaults.integer(forKey: "previewWidth")
        previewWidth = pw == 0 ? 400 : pw
        // Apply defaults when a key is missing
        if let v = defaults.object(forKey: "topLeft") as? Bool {
            topLeft = v
        } else {
            topLeft = true
        }
        topRight = (defaults.object(forKey: "topRight") as? Bool) ?? false
        bottomLeft = (defaults.object(forKey: "bottomLeft") as? Bool) ?? false
        bottomRight = (defaults.object(forKey: "bottomRight") as? Bool) ?? false
        openOnClick = defaults.object(forKey: "openOnClick") as? Bool ?? true
        
        shortcutEnabled  = defaults.bool(forKey: "shortcutEnabled")
        if let raw = defaults.string(forKey: "shortcutCorner"),
           let c = Corner(rawValue: raw) {
            shortcutCorner = c
        }
        
        if let path = defaults.string(forKey: "filePath") {
            fileURL = URL(fileURLWithPath: path)
        }
    }
    
    func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(previewLines, forKey: "previewLines")
        defaults.set(previewWidth, forKey: "previewWidth")
        defaults.set(topLeft, forKey: "topLeft")
        defaults.set(topRight, forKey: "topRight")
        defaults.set(bottomLeft, forKey: "bottomLeft")
        defaults.set(bottomRight, forKey: "bottomRight")
        defaults.set(openOnClick, forKey: "openOnClick")
        
        defaults.set(shortcutEnabled,  forKey: "shortcutEnabled")
        defaults.set(shortcutCorner.rawValue, forKey: "shortcutCorner")
        
        if let url = fileURL {
            defaults.set(url.path, forKey: "filePath")
        }
    }
    
}
