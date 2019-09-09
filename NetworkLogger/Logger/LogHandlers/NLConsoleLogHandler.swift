//
//  ConsoleLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class NLConsoleLogHandler: NLBaseLogHandler, NLLogHandler {
    
    private var logComposer: NLLogComposer!
    
    @objc public class func create() -> NLConsoleLogHandler {
        let instance: NLConsoleLogHandler = NLConsoleLogHandler()
        instance.logComposer = NLLogComposer(logFormatter: instance.logFormatter)
        return instance
    }
    
    private override init() {
        super.init()
    }
    
    public func networkLogger(logRequest logData: NLLogData) {
        
        if shouldLogRequest(logData: logData) {
            print(logComposer.getRequestLog(from: logData))
        }
    }
    
    public func networkLogger(logResponse logData: NLLogData) {
        
        if shouldLogResponse(logData: logData) {
            print(logComposer.getResponseLog(from: logData))
        }
    }
    
}
