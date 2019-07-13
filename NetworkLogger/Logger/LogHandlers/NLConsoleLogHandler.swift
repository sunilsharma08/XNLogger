//
//  ConsoleLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class NLConsoleLogHandler: NLBaseLogHandler, NLLogHandler {
    
    private let logComposer = LogComposer()
    
    public class func create() -> NLConsoleLogHandler {
        return NLConsoleLogHandler()
    }
    
    public func logNetworkRequest(from logData: NLLogData) {
        if isAllowed(urlRequest: logData.urlRequest) {
            print(logComposer.getRequestLog(from: logData))
        }
    }
    
    public func logNetworkResponse(from logData: NLLogData) {
        
        if isAllowed(urlRequest: logData.urlRequest) {
            print(logComposer.getResponseLog(from: logData))
        }
    }
    
}
