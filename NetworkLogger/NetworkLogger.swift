//
//  NetworkLogger.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 16/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import Foundation

@objc public class NetworkLogger: NSObject {
    
    // Public variables
    @objc public static let shared = NetworkLogger()
    
    // Private variables
    private let networkInterceptor = NetworkInterceptor()
    private(set) var handlers: [NLLogHandler] = []
    
    private(set) var filters: [NLFilter] = []
    
    override private init() {}
    
    @objc public func startLogging() {
        debugPrint("Started logging network traffic")
        networkInterceptor.startInterceptingNetwork()
    }
    
    @objc public func stopLogging() {
        debugPrint("Stopped logging network traffic")
        networkInterceptor.stopInterceptingNetwork()
    }
    
    public func addLogHandler(_ handler: NLLogHandler) {
        self.handlers.append(handler)
    }
    
    public func addLogHandlers(_ handlers: [NLLogHandler]) {
        self.handlers.append(contentsOf: handlers)
    }
    
    public func removeHandler(_ handler: NLLogHandler) {
        self.handlers = self.handlers.filter { (item) -> Bool in
            return item !== handler
        }
    }
    
    @objc public func removeAllHandlers() {
        self.handlers.removeAll()
    }
    
    // MARK: Methods to handle Skip URLs from Network Logger
    
    /**
     URL filter added will not go through Network Logger.
    */
    public func skipURLs(urlFilters: [NLFilter]) {
        for filter in urlFilters {
            filter.invert = true
            self.filters.append(filter)
        }
    }
    
    /**
     Remove specified url filter from skip urls list
    */
    public func removeSkipURL(filter: NLFilter) {
        self.filters = self.filters.filter { (item) -> Bool in
            return item !== filter
        }
    }
    
    /**
     Remove all filters from skip urls list
    */
    public func removeAllSkipURLs() {
        self.filters.removeAll()
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
        if !isRemoteLogRequest(urlRequest) {
            for handler in self.handlers {
                handler.logNetworkResponse(for: urlRequest, responseData: responseData)
            }
        }
    }
    
    func logRequest(_ urlRequest: URLRequest) {
        if !isRemoteLogRequest(urlRequest) {
            for handler in self.handlers {
                handler.logNetworkRequest(urlRequest)
            }
        }
    }
    
    private func isRemoteLogRequest(_ urlRequest: URLRequest) -> Bool {
        
        if let _ = urlRequest.allHTTPHeaderFields?[AppConstants.LogRequestKey] {
            return true
        } else {
            return false
        }
    }
    
}
