//
//  XNLogger.swift
//  XNLogger
//
//  Created by Sunil Sharma on 16/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import Foundation

@objc public protocol XNLoggerDelegate: AnyObject {

    @objc optional func xnLogger(didStartRequest logData: XNLogData)
    @objc optional func xnLogger(didReceiveResponse logData: XNLogData)
}

@objcMembers
public class XNLogger: NSObject, @unchecked Sendable {

    // Public variables
    public static let shared = XNLogger()
    public weak var delegate: XNLoggerDelegate?

    // Private variables
    private let networkInterceptor = XNInterceptor()

    /// Lock protecting the handlers array. Handlers are written during setup
    /// (main thread) and read during network interception (background threads).
    private let handlersLock = NSLock()
    private var _handlers: [XNLogHandler] = []

    /// Thread-safe access to the handlers list.
    private(set) public var handlers: [XNLogHandler] {
        get {
            handlersLock.lock()
            defer { handlersLock.unlock() }
            return _handlers
        }
        set {
            handlersLock.lock()
            defer { handlersLock.unlock() }
            _handlers = newValue
        }
    }

    let filterManager: XNFilterManager = XNFilterManager()

    override private init() {}

    public func startLogging() {
        networkInterceptor.startInterceptingNetwork()
        // Ensure XNUIManager (and its log handler) is initialized eagerly
        _ = XNUIManager.shared
    }

    public func stopLogging() {
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
        handlersLock.lock()
        defer { handlersLock.unlock() }
        _handlers.append(contentsOf: handlers)
    }

    /**
     Remove given list of handlers.

     - Parameters handlers: List of handlers to be removed.
     */
    public func removeHandlers(_ handlers: [XNLogHandler]) {
        handlersLock.lock()
        defer { handlersLock.unlock() }
        for handler in handlers {
            _handlers = _handlers.filter { (item) -> Bool in
                return item !== handler
            }
        }
    }

    /**
     Remove all added handlers.
     */
    public func removeAllHandlers() {
        handlersLock.lock()
        defer { handlersLock.unlock() }
        _handlers.removeAll()
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
        // Take a snapshot of handlers to iterate safely.
        let currentHandlers = handlers
        for handler in currentHandlers {
            if let fileHandler = handler as? XNFileLogHandler {
                fileHandler.clearLogFiles()
            }
        }
    }

    func logResponse(from logData: XNLogData) {
        // Take a snapshot of handlers to iterate safely.
        let currentHandlers = handlers
        for handler in currentHandlers {
            handler.xnLogger?(logResponse: logData)
        }
    }

    func logRequest(from logData: XNLogData) {
        // Take a snapshot of handlers to iterate safely.
        let currentHandlers = handlers
        for handler in currentHandlers {
            handler.xnLogger?(logRequest: logData)
        }
    }

}
