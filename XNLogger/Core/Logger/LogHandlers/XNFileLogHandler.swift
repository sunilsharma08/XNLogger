//
//  XNFileLogHandler.swift
//  XNLogger
//
//  Created by Sunil Sharma on 04/03/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public class XNFileLogHandler: XNBaseLogHandler, XNLogHandler {
    
    private var logComposer: XNLogComposer!
    private(set) var fileName: String = "XNNetworkLog"
    private let fileManager = FileManager.default
    private let fileWriteQueue = DispatchQueue(label: "com.xnLogger.fileHandler", qos: .utility)
    
    // The max size a log file can be in Kilobytes. Default is 1024 (1 MB)
    public var maxFileSize: UInt64 = 1024
    
    // The max number of log file that will be stored. Once this point is reached, the oldest file is deleted.
    public var maxFileCount = 4
    
    public class func create(fileName: String? = nil) -> XNFileLogHandler {
        let instance: XNFileLogHandler = XNFileLogHandler(fileName: fileName)
        instance.logComposer = XNLogComposer(logFormatter: instance.logFormatter)
        return instance
    }
    
    private init(fileName: String?) {
        if let fileName = fileName, !fileName.isEmpty {
            self.fileName = fileName
        }
    }
    
    // The directory in which the log files will be written
    open var directory = XNFileLogHandler.defaultDirectory() {
        didSet {
            directory = NSString(string: directory).expandingTildeInPath
            createLogDirectory()
        }
    }
    
    func createLogDirectory() {
        if !fileManager.fileExists(atPath: directory) {
            do {
                try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                debugPrint("Couldn't create directory at \(directory)")
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    public var currentPath: String {
        return "\(directory)/\(logName(0))"
    }
    
    // Get the default log directory
    class public func defaultDirectory() -> String {
        var path = ""
        let fileManager = FileManager.default
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        
        // Check atleast one path exists
        guard paths.count > 0
        else { return path }
        path = "\(paths[0])/XNLogger/FileLogHandler"
        if !fileManager.fileExists(atPath: path) && !path.isEmpty  {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
        return path
    }
    
    // Check the size of a file
    private func fileSize(_ path: String) -> UInt64 {
        let attrs: NSDictionary? = try? self.fileManager.attributesOfItem(atPath: path) as NSDictionary
        if let dict = attrs {
            return dict.fileSize()
        }
        return 0
    }
    
    // Write content to the current log file.
    open func write(_ text: String) {
        let path = self.currentPath
        if !self.fileManager.fileExists(atPath: path) {
            if !self.fileManager.fileExists(atPath: self.directory) {
                self.createLogDirectory()
            }
            do {
                try "".write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            let dateStr = self.dateFormatter.string(from: Date())
            let writeText = "[\(dateStr)]: \(text)\n"
            fileHandle.seekToEndOfFile()
            fileHandle.write(writeText.data(using: String.Encoding.utf8)!)
            fileHandle.synchronizeFile()
            fileHandle.closeFile()
            self.cleanup()
        }
    }
    
    // Do the checks and cleanup
    private func cleanup() {
        let path = "\(directory)/\(logName(0))"
        let size = fileSize(path)
        let maxSize: UInt64 = maxFileSize*1024
        if size > 0 && size >= maxSize && maxSize > 0 && maxFileCount > 0 {
            rename(0)
            // Delete the oldest file
            let deletePath = "\(directory)/\(logName(maxFileCount))"
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: deletePath)
            } catch let error {
                debugPrint("Failed to delete file \(deletePath)")
                debugPrint(error.localizedDescription)
            }
        }
    }
    
    // Recursive method call to rename log files
    private func rename(_ index: Int) {
        let path = "\(directory)/\(logName(index))"
        let newPath = "\(directory)/\(logName(index+1))"
        if self.fileManager.fileExists(atPath: newPath) {
            rename(index+1)
        }
        do {
            try self.fileManager.moveItem(atPath: path, toPath: newPath)
        } catch let error {
            debugPrint("Failed to move file \(path) to path \(newPath)")
            debugPrint(error.localizedDescription)
        }
    }
    
    // The date formatter
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        return formatter
    }
    
    // Gets the log name
    private func logName(_ num: Int) -> String {
        return "\(self.fileName)-\(num).log"
    }
    
    public func clearLogFiles() {
        guard self.fileManager.fileExists(atPath: directory)
        else { return }
        do {
            try fileManager.removeItem(atPath: directory)
        }
        catch let error as NSError {
            debugPrint(error.debugDescription)
        }
    }
    
    //MARK: Logging delegates
    public func xnLogger(logRequest logData: XNLogData) {
        self.fileWriteQueue.async { [weak self] in
            guard let self = self else { return }
            
            if self.shouldLogRequest(logData: logData) {
                self.write(self.logComposer.getRequestLog(from: logData))
            }
        }
    }
    
    public func xnLogger(logResponse logData: XNLogData) {
        self.fileWriteQueue.async {[weak self] in
            guard let self = self else { return }
            
            if self.shouldLogResponse(logData: logData) {
                self.write(self.logComposer.getResponseLog(from: logData))
            }
        }
    }
}
