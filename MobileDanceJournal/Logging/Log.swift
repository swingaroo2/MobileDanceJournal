//
//  Logger.swift
//  MobileDanceJournal
//
//  Created by Zach Lockett-Streiff on 10/30/19.
//  Copyright © 2019 Swingaroo2. All rights reserved.
//

import Foundation
import Logging

struct Log {
    private static var logger = Logger(label: Bundle.main.bundleIdentifier!)
    static var logLevel: Logger.Level {
        get {
            return logger.logLevel
        }
    
        set {
            logger.logLevel = newValue
        }
    }
}

// MARK: - Log Function Wrappers
extension Log {
    static func trace(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fullMessage = buildLogMessage(message, file: file, function: function, line: line, emoji: "🕵🏽‍♂️")
        logger.log(level: .trace, fullMessage)
    }
    
    static func info(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fullMessage = buildLogMessage(message, file: file, function: function, line: line, emoji: "ℹ")
        logger.log(level: .info, fullMessage)
    }
    
    static func debug(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fullMessage = buildLogMessage(message, file: file, function: function, line: line, emoji: "🐞")
        logger.log(level: .debug, fullMessage)
    }
    
    static func notice(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fullMessage = buildLogMessage(message, file: file, function: function, line: line, emoji: "❕")
        logger.log(level: .notice, fullMessage)
    }
    
    static func warn(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fullMessage = buildLogMessage(message, file: file, function: function, line: line, emoji: "⚠️")
        logger.log(level: .warning, fullMessage)
    }
    
    static func error(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fullMessage = buildLogMessage(message, file: file, function: function, line: line, emoji: "❗️")
        logger.log(level: .error, fullMessage)
    }
    
    static func critical(_ message: String = "", file: String = #file, function: String = #function, line: Int = #line) {
        let fullMessage = buildLogMessage(message, file: file, function: function, line: line, emoji: "‼️")
        logger.log(level: .critical, fullMessage)
    }
}

// MARK: - Private Methods
private extension Log {
    static func buildLogMessage(_ message: String, file: String = #file, function: String = #function, line: Int = #line, emoji: String) -> Logger.Message {
        let className = URL(string: file.replacingOccurrences(of: " ", with: ""))!.lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        let fullMessage = message == "" ? "\(emoji) \(className) \(line) \(function)" : "\(emoji) \(className) \(line) \(function) -- \(message)"
        let message = Logger.Message(stringLiteral: fullMessage)
        return message
    }
}
