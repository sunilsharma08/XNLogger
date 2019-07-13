//
//  NetworkLogger.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 16/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import Foundation

@objc public protocol NetworkLoggerDelegate: class {
    
    @objc optional func networkLogger(didStartRequest logData: NLLogData)
    @objc optional func networkLogger(didReceiveResponse logData: NLLogData)
}

@objc public class NetworkLogger: NSObject {
    
    // Public variables
    @objc public static let shared = NetworkLogger()
    @objc public weak var delegate: NetworkLoggerDelegate?
    
    // Private variables
    private let networkInterceptor = NetworkInterceptor()
    
    private(set) var handlers: [NLLogHandler] = []
    let filterManager: NLFilterManager = NLFilterManager()
    
    override private init() {}
    
    @objc public func startLogging() {
        debugPrint("Started logging network traffic")
        networkInterceptor.startInterceptingNetwork()
    }
    
    @objc public func stopLogging() {
        debugPrint("Stopped logging network traffic")
        networkInterceptor.stopInterceptingNetwork()
    }
    
    public func addLogHandlers(_ handlers: [NLLogHandler]) {
        self.handlers.append(contentsOf: handlers)
    }
    
    public func removeHandlers(_ handlers: [NLLogHandler]) {
        for handler in handlers {
            self.handlers = self.handlers.filter { (item) -> Bool in
                return item !== handler
            }
        }
    }
    
    @objc public func removeAllHandlers() {
        self.handlers.removeAll()
    }
    
    // MARK: Methods to handle Skip URLs from Network Logger
    
    /**
     URL filter added will not go through Network Logger.
    */
    public func addFilters(_ filters: [NLFilter]) {
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
    
    public func update(filterType: NLFilterType, toInvertMode state: Bool) {
        filterManager.update(filterType: filterType, toInvertMode: state)
    }
    
    /**
     Clear all logs in-memory and disk cache
     */
    @objc public func clearLogs() {
        for handler in handlers {
            if let fileHandler = handler as? NLFileLogHandler {
                fileHandler.clearLogFiles()
            }
        }
    }
    
    func logResponse(for urlRequest: URLRequest, responseData: NLResponseData) {
        for handler in self.handlers {
            handler.logNetworkResponse(for: urlRequest, responseData: responseData)
        }
    }
    
    func logRequest(_ urlRequest: URLRequest) {
        for handler in self.handlers {
            handler.logNetworkRequest(urlRequest)
        }
    }
    
}
