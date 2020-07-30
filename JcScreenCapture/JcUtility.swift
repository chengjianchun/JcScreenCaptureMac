import Foundation
import SwiftUI
import Carbon

public class JcUtility {
    
    static func capture(path: String) {
        let img = CGDisplayCreateImage(CGMainDisplayID())
        let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: path) as CFURL, kUTTypeJPEG, 1, nil)
        defer {
            CGImageDestinationFinalize(dest!)
        }
        let options: NSDictionary = [
            kCGImageDestinationLossyCompressionQuality: 0.1
        ]
        CGImageDestinationAddImage(dest!, img!, options)
    }
    
    static func getCapturePath(parent: String) throws -> String {
        let now = self.getLocalTime()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let dir = NSString(string: parent).appendingPathComponent(df.string(from: now))
        try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        df.dateFormat = "yyyyMMdd-HHmmss"
        return NSString(string: dir).appendingPathComponent(df.string(from: now) + ".jpg")
    }

    static func clearFileSystemItems(parent: String, beforeDays: Int, clearFiles: Bool = false, clearDirs: Bool = false) {
        do {
            if let dt = Calendar.current.date(byAdding: .day, value: 1 - beforeDays, to: self.getLocalTime()) {

                let contents = try FileManager.default.contentsOfDirectory(atPath: parent)
                for content in contents {
                    let path = NSString(string: parent).appendingPathComponent(content)
                    if (clearFiles && isFile(path: path)) || (clearDirs && isDir(path: path)) {
                        if let date = try self.getCreationDate(path: path) {
                            if date < dt {
                                try FileManager.default.removeItem(atPath: path)
                            }
                        }
                    }
                }
            }
        } catch let err {
            self.log("clearFileSystemItems error: \(err)")
            self.logStackSymbols()
        }
    }

    static func isDir(path: String) -> Bool {
        var ob = ObjCBool.init(false)
        return FileManager.default.fileExists(atPath: path, isDirectory: &ob) && ob.boolValue
    }
    
    static func isFile(path: String) -> Bool {
        var ob = ObjCBool.init(false)
        return FileManager.default.fileExists(atPath: path, isDirectory: &ob) && !ob.boolValue
    }
    
    static func convertToLocal(date: Date) -> Date {
        let zone = NSTimeZone.local
        let second = zone.secondsFromGMT()
        return date.addingTimeInterval(TimeInterval(second))
    }
    
    static func getLocalTime() -> Date {
        return self.convertToLocal(date: Date())
    }
    
    static func getCreationDate(path: String) throws -> Date? {
        let attrs = try FileManager.default.attributesOfItem(atPath: path)
        if let date = attrs[FileAttributeKey.creationDate] {
            return self.convertToLocal(date: date as! Date)
        }
        return nil
    }

    static func writeFile(_ content: String, path: String) {
        let data = (content + "\n").data(using: String.Encoding.utf8)!
        if self.isFile(path: path) {
            if let fh = FileHandle(forWritingAtPath: path) {
                defer {
                    fh.closeFile()
                }
                fh.seekToEndOfFile()
                fh.write(data)
            }
        }
        else {
            try? data.write(to: URL(fileURLWithPath: path))
        }
    }
    
    static func log(_ content: String) {
        try? FileManager.default.createDirectory(atPath: JcConfig.shared.logDir, withIntermediateDirectories: true, attributes: nil)
        let now = self.getLocalTime()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let path = NSString(string: JcConfig.shared.logDir).appendingPathComponent(df.string(from: now) + ".txt")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss "
        self.writeFile(df.string(from: now) + content, path: path)
    }
    
    static func logStackSymbols() {
        self.log(Thread.callStackSymbols.joined(separator: "\n"))
    }
}
