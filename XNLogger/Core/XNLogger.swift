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
        print("NL: Started logging network traffic")
        networkInterceptor.startInterceptingNetwork()
    }
    
    public func stopLogging() {
        print("NL: Stopped logging network traffic")
        networkInterceptor.stopInterceptingNetwork()
    }
    
    public func addLogHandlers(_ handlers: [XNLogHandler]) {
        self.handlers.append(contentsOf: handlers)
    }
    
    public func removeHandlers(_ handlers: [XNLogHandler]) {
        for handler in handlers {
            self.handlers = self.handlers.filter { (item) -> Bool in
                return item !== handler
            }
        }
    }
    
    public func removeAllHandlers() {
        self.handlers.removeAll()
    }
    
    // MARK: Methods to handle Skip URLs from Network Logger
    
    /**
     URL filter added will not go through Network Logger.
    */
    @objc public func addFilters(_ filters: [NLFilter]) {
        self.filterManager.addFilters(filters)
    }
    
    /**
     Remove specified url filter from skip urls list
    */
    public func removeFilters(_ filters: [NLFilter]) {
        self.filterManager.removeFilters(filters)
    }
    
    /**
     Remove all filters from skip urls list
    */
    public func removeAllFilters() {
        self.filterManager.removeAllFilters()
    }
    
    public func filters() -> [NLFilter] {
        return filterManager.getFilters()
    }
    
    public func update(filterType: XNFilterType, toInvertMode state: Bool) {
        filterManager.update(filterType: filterType, toInvertMode: state)
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
