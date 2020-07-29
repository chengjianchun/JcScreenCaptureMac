import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var appName: String
    var appDir: String
    var screenshotDir: String
    var logDir: String
    var interval: UInt32

    override init() {
        appName = "JcScreenCapture"
        appDir = NSString(string: NSHomeDirectory()).appendingPathComponent(appName)
        screenshotDir = NSString(string: appDir).appendingPathComponent("screenshot")
        logDir = NSString(string: appDir).appendingPathComponent("log")
        interval = 60
    
        super.init()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.startCaptrue()
    }
    
    func startCaptrue() {
        Thread.detachNewThread {
            while true {
                self.capture()
                sleep(self.interval)
            }
        }
    }

//    func capture() {
//        let df = DateFormatter()
//        df.dateFormat = "yyyyMMdd-HHmmss"
//        let s = df.string(from: Date())
//        let file = "/Users/Shared/JcScreenCapture/\(s).jpg"
//
//        let task = Process()
//        let pipe = Pipe()
//        task.launchPath = "/usr/sbin/screencapture"
//        task.arguments = ["-Cxtjpg", file]
//        task.standardOutput = pipe
//        task.launch()
//        task.waitUntilExit()
//    }

    func capture() {
        let path = self.getPath()
        print(path)

        let img = CGDisplayCreateImage(CGMainDisplayID())
        let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, kUTTypeJPEG, 1, nil)
        defer {
            CGImageDestinationFinalize(dest!)
        }
        CGImageDestinationAddImage(dest!, img!, nil)
    }
    
    func getPath() -> String {
        let now = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let dir = NSString(string: self.screenshotDir).appendingPathComponent(df.string(from: now))
        try! FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        df.dateFormat = "yyyyMMdd-HHmmss"
        return NSString(string: dir).appendingPathComponent(df.string(from: now) + ".jpg")
    }
    
}
