import Foundation

enum LaunchAgentError: Error {
    case writeFailed(Error)
    case removeFailed(Error)
    case launchctlFailed(Int32)
}

struct LaunchAgentHelper {
    private static var bundleID: String {
        Bundle.main.bundleIdentifier!
    }
    private static var agentsDir: String {
        ("~/Library/LaunchAgents" as NSString).expandingTildeInPath
    }
    static  var plistPath: String {
        (agentsDir as NSString).appendingPathComponent("\(bundleID).plist")
    }
    private static var execPath: String {
        Bundle.main.bundlePath + "/Contents/MacOS/" + ProcessInfo.processInfo.processName
    }
    private static var uidDomain: String {
        "gui/\(getuid())"
    }
    
    static func enable() throws {
        let fm = FileManager.default
        
        try fm.createDirectory(atPath: agentsDir,
                               withIntermediateDirectories: true,
                               attributes: nil)
        
        let plist = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
          <dict>
            <key>Label</key><string>\(bundleID)</string>
            <key>ProgramArguments</key>
            <array><string>\(execPath)</string></array>
            <key>RunAtLoad</key><true/></dict>
        </plist>
        """
        // Write plist
        do {
            try plist.write(toFile: plistPath, atomically: true, encoding: .utf8)
        } catch {
            throw LaunchAgentError.writeFailed(error)
        }
        // Ensure idempotency: try to bootout if already loaded (ignore errors)
        _ = runLaunchctl(["bootout", uidDomain, bundleID])
        // Bootstrap (load) the agent
        let code = runLaunchctl(["bootstrap", uidDomain, plistPath])
        guard code == 0 else { throw LaunchAgentError.launchctlFailed(code) }
        // Enable the agent (in case it was disabled previously)
        _ = runLaunchctl(["enable", uidDomain + "/" + bundleID])
    }
    
    static func disable() throws {
        // 1) bootout (unload) and disable
        _ = runLaunchctl(["bootout", uidDomain, bundleID])
        let code = runLaunchctl(["disable", uidDomain + "/" + bundleID])
        guard code == 0 else { throw LaunchAgentError.launchctlFailed(code) }
        let fm = FileManager.default
        if fm.fileExists(atPath: plistPath) {
            do {
                try fm.removeItem(atPath: plistPath)
            } catch {
                throw LaunchAgentError.removeFailed(error)
            }
        }  
    }
    
    @discardableResult
    private static func runLaunchctl(_ args: [String]) -> Int32 {
        let proc = Process()
        proc.launchPath = "/bin/launchctl"
        proc.arguments   = args
        proc.launch()
        proc.waitUntilExit()
        return proc.terminationStatus
    }
}
