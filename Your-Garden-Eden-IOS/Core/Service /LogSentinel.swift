// DATEI: LogSentinel.swift
// PFAD: Services/Logging/LogSentinel.swift
// ZWECK: Die zentrale, hochpräzise Protokollierungs-Engine "LogSentinel".

import Foundation

public final class LogSentinel {
    
    public static let shared = LogSentinel()
    
    private let logQueue = DispatchQueue(label: "com.yourgardeneden.logsentinel.queue")
    
    private let dateFormatter: DateFormatter
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    }
    
    private func log(level: LogLevel, message: String, file: String, function: String, line: UInt) {
        let timestamp = dateFormatter.string(from: Date())
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let logMessage = "\(timestamp) \(level.icon) [\(fileName):\(line) \(function)] > \(message)"
        
        logQueue.async {
            if level == .fatal {
                fatalError(logMessage)
            } else {
                print(logMessage)
            }
        }
    }
    
    public func debug(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .debug, message: message, file: file, function: function, line: line)
    }
    
    public func info(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }
    
    public func notice(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .notice, message: message, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }
    
    public func fatal(_ message: String, file: String = #file, function: String = #function, line: UInt = #line) {
        log(level: .fatal, message: message, file: file, function: function, line: line)
    }
}
