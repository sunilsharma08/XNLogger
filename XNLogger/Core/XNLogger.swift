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

/// Represents a log event emitted by XNLogger.
public enum XNLogEvent: Sendable {
    case request(XNLogData)
    case response(XNLogData)
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

    // MARK: - AsyncStream support

    private let continuationsLock = NSLock()
    private var _continuations: [UUID: AsyncStream<XNLogEvent>.Continuation] = [:]

    /// An `AsyncStream` of log events. Each caller receives an independent stream.
    /// The stream yields `.request` and `.response` events as they occur.
    ///
    /// Usage:
    /// ```swift
    /// for await event in XNLogger.shared.logStream {
    ///     switch event {
    ///     case .request(let data):
    ///         print("Request: \(data.urlRequest.url)")
    ///     case .response(let data):
    ///         print("Response: \(data.response)")
    ///     }
    /// }
    /// ```
    public var logStream: AsyncStream<XNLogEvent> {
        let id = UUID()
        return AsyncStream { continuation in
            continuationsLock.lock()
            _continuations[id] = continuation
            continuationsLock.unlock()

            continuation.onTermination = { @Sendable _ in
                self.continuationsLock.lock()
                self._continuations.removeValue(forKey: id)
                self.continuationsLock.unlock()
            }
        }
    }

    private func yieldToStreams(_ event: XNLogEvent) {
        continuationsLock.lock()
        let activeContinuations = _continuations.values
        continuationsLock.unlock()

        for continuation in activeContinuations {
            continuation.yield(event)
        }
    }

    // MARK: - Combine support (subject storage)

    /// Internal subject for Combine publisher. Created lazily in XNLogger+Combine.swift.
    private let _subjectLock = NSLock()
    private var _logSubject: AnyObject?

    /// Thread-safe accessor for the internal Combine subject.
    func getOrCreateLogSubject<T: AnyObject>(create: () -> T) -> T {
        _subjectLock.lock()
        defer { _subjectLock.unlock() }
        if let existing = _logSubject as? T {
            return existing
        }
        let subject = create()
        _logSubject = subject
        return subject
    }

    func sendToSubject(_ event: XNLogEvent) {
        _subjectLock.lock()
        let subject = _logSubject
        _subjectLock.unlock()

        // Dynamically call send if subject exists — avoids importing Combine here.
        // The actual typed send is done in XNLogger+Combine.swift via the stored closure.
        if let sendClosure = _combineSendClosure {
            sendClosure(event)
        }
        _ = subject // Suppress unused warning
    }

    /// Closure set by XNLogger+Combine.swift to send events without importing Combine in this file.
    var _combineSendClosure: ((XNLogEvent) -> Void)?

    // MARK: - Init

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
        let event = XNLogEvent.response(logData)
        yieldToStreams(event)
        sendToSubject(event)
    }

    func logRequest(from logData: XNLogData) {
        // Take a snapshot of handlers to iterate safely.
        let currentHandlers = handlers
        for handler in currentHandlers {
            handler.xnLogger?(logRequest: logData)
        }
        let event = XNLogEvent.request(logData)
        yieldToStreams(event)
        sendToSubject(event)
    }

}
