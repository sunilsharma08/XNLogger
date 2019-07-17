//
//  NLBaseLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 05/03/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public class NLBaseLogHandler: NSObject {
    
    private var filterManager: NLFilterManager = NLFilterManager()
    public let logFormatter: NLLogFormatter = NLLogFormatter()
    
    public func addFilters(_ filters: [NLFilter]) {
        self.filterManager.addFilters(filters)
    }
    
    public func removeAllFilters() {
        self.filterManager.removeAllFilters()
    }
    
    public func shouldLogRequest(logData: NLLogData) -> Bool {
        return logFormatter.showRequest && filterManager.isAllowed(urlRequest: logData.urlRequest)
    }
    
    public func shouldLogResponse(logData: NLLogData) -> Bool {
        return logFormatter.showResponse && filterManager.isAllowed(urlRequest: logData.urlRequest)
    }
}
