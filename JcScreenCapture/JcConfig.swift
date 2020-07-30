import Foundation

public class JcConfig {
    static var shared: JcConfig = JcConfig()
    
    var appName: String
    var appDir: String
    var screenshotDir: String
    var logDir: String
    var interval: UInt32
    var clearDays: Int

    init() {
        appName = "JcScreenCapture"
        appDir = NSString(string: NSHomeDirectory()).appendingPathComponent(appName)
        screenshotDir = NSString(string: appDir).appendingPathComponent("screenshot")
        logDir = NSString(string: appDir).appendingPathComponent("log")
        interval = 60
        clearDays = 10
    }
}
