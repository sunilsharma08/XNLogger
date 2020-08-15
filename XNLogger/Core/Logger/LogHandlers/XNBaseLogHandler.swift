//
//  XNBaseLogHandler.swift
//  XNLogger
//
//  Created by Sunil Sharma on 05/03/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

/**
 Base class for log handler. Not necessary to subclasss if you create your own handler.
 It just provide some convient methods to child class.
 */
@objc open class XNBaseLogHandler: NSObject {
    
    private var filterManager: XNFilterManager = XNFilterManager()
    public let logFormatter: XNLogFormatter = XNLogFormatter()
    
    open func addFilters(_ filters: [XNFilter]) {
        self.filterManager.addFilters(filters)
    }
    
    open func removeFilters(_ filters: [XNFilter]) {
        self.filterManager.removeFilters(filters)
    }
    
    open func removeAllFilters() {
        self.filterManager.removeAllFilters()
    }
    
    open func shouldLogRequest(logData: XNLogData) -> Bool {
        return logFormatter.showRequest && filterManager.isAllowed(urlRequest: logData.urlRequest)
    }
    
    open func shouldLogResponse(logData: XNLogData) -> Bool {
        return logFormatter.showResponse && filterManager.isAllowed(urlRequest: logData.urlRequest)
    }
}
