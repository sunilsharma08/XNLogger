//
//  XNLogger.swift
//  XNLogger
//
//  Created by Sunil Sharma on 16/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import Foundation

@objc public protocol XNLoggerDelegate: class {
    
    @objc optional func xnLogger(didStartRequest logData: XNLogData)
    @objc optional func xnLogger(didReceiveResponse logData: XNLogData)
}

@objcMembers
public class XNLogger: NSObject {
    
    // Public variables
    public static let shared = XNLogger()
    public weak var delegate: XNLoggerDelegate?
    
    // Private variables
    private let networkInterceptor = XNInterceptor()
    
    private(set) public var handlers: [XNLogHandler] = []
    let filterManager: XNFilterManager = XNFilterManager()
    
    override private init() {}
    
    public func startLogging() {
        // print(": Started logging network traffic")
        networkInterceptor.startInterceptingNetwork()
    }
    
    public func stopLogging() {
        // print("XNL: Stopped logging network traffic")
        networkInterceptor.stopInterceptingNetwork()
    }
    
    /**
     Checks whether logging is enabled or not.
     */
    public func isEnabled() -> Bool {
        return networkInterceptor.isProtocolSwizzled()
    }
    
    /**
     Add given list of handlers.
     
     - Parameters handlers: List of handlers to be added.
     */
    public func addLogHandlers(_ handlers: [XNLogHandler]) {
        self.handlers.append(contentsOf: handlers)
    }
    
    /**
     Remove given list of handlers.
     
     - Parameters handlers: List of handlers to be removed.
     */
    public func removeHandlers(_ handlers: [XNLogHandler]) {
        for handler in handlers {
            self.handlers = self.handlers.filter { (item) -> Bool in
                return item !== handler
            }
        }
    }
    
    /**
     Remove all added handlers.
     */
    public func removeAllHandlers() {
        self.handlers.removeAll()
    }
    
    // MARK: Filters methods for logger
    
    /**
     URL filter added will not go through Network Logger.
    */
    @objc public func addFilters(_ filters: [XNFilter]) {
        self.filterManager.addFilters(filters)
    }
    
    /**
     Remove specified url filter for logger.
    */
    public func removeFilters(_ filters: [XNFilter]) {
        self.filterManager.removeFilters(filters)
    }
    
    /**
     Remove all logger filters.
    */
    public func removeAllFilters() {
        self.filterManager.removeAllFilters()
    }
    
    /**
     Gives list of all logger filters.
     */
    public func filters() -> [XNFilter] {
        return filterManager.getFilters()
    }
    
    /**
     Clear all logs in-memory and disk cache
     */
    public func clearLogs() {
        for handler in handlers {
            if let fileHandler = handler as? XNFileLogHandler {
                fileHandler.clearLogFiles()
            }
        }
    }
    
    func logResponse(from logData: XNLogData) {
        for handler in self.handlers {
            handler.xnLogger?(logResponse: logData)
        }
    }
    
    func logRequest(from logData: XNLogData) {
        for handler in self.handlers {
            handler.xnLogger?(logRequest: logData)
        }
    }
    
}
