import Cocoa
import SwiftUI
import Carbon

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        JcUtility.log("start...")
        self.autoStart()
        self.regHotkey(keyCode: kVK_ANSI_J, modifierFlags: [.control, .shift])
        self.startCaptrue()
        self.clearScreenshots()
        self.clearLogs()
    }
    
    func regHotkey(keyCode: Int, modifierFlags: NSEvent.ModifierFlags) {
//        let opts = NSDictionary(object: kCFBooleanTrue!, forKey: kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString) as CFDictionary
//        guard AXIsProcessTrustedWithOptions(opts) == true else { return }
        
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { (e: NSEvent) in
            if e.keyCode == keyCode && modifierFlags.isSubset(of: e.modifierFlags) {
                NSWorkspace.shared.openFile(JcConfig.shared.screenshotDir)
            }
        }
    }
    
    func startCaptrue() {
        Thread.detachNewThread {
            while true {
                do {
                    let path = try JcUtility.getCapturePath(parent: JcConfig.shared.screenshotDir)
                    JcUtility.capture(path: path)
                } catch let err {
                    JcUtility.log("capture thread error: \(err)")
                    JcUtility.logStackSymbols()
                }
                sleep(JcConfig.shared.interval)
            }
        }
    }
    
    func clearScreenshots() {
        JcUtility.clearFileSystemItems(parent: JcConfig.shared.screenshotDir, beforeDays: JcConfig.shared.clearDays, clearDirs: true)
    }
    
    func clearLogs() {
        JcUtility.clearFileSystemItems(parent: JcConfig.shared.logDir, beforeDays: JcConfig.shared.clearDays, clearFiles: true)
    }
    
    func autoStart() {
        let path = NSString.path(withComponents: [NSHomeDirectory(), "Library", "LaunchAgents", "space.jianchun.JcScreenCapture.plist"])
        if !JcUtility.isFile(path: path) {
            JcUtility.writeFile("""
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
            <plist version="1.0">
            <dict>
                <key>Label</key>
                <string>space.jianchun.JcScreenCapture</string>
                <key>ProgramArguments</key>
                <array>
                    <string>/Applications/JcScreenCapture.app/Contents/MacOS/JcScreenCapture</string>
                </array>
                <key>RunAtLoad</key>
                <true/>
            </dict>
            </plist>
            """, path: path)
        }
    }

}
