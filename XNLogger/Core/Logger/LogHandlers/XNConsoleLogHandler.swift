//
//  XNConsoleLogHandler.swift
//  XNLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class XNConsoleLogHandler: XNBaseLogHandler, XNLogHandler {
    
    private var logComposer: XNLogComposer!
    
    @objc public class func create() -> XNConsoleLogHandler {
        let instance: XNConsoleLogHandler = XNConsoleLogHandler()
        instance.logComposer = XNLogComposer(logFormatter: instance.logFormatter)
        return instance
    }
    
    private override init() {
        super.init()
    }
    
    public func xnLogger(logRequest logData: XNLogData) {
        
        if shouldLogRequest(logData: logData) {
            print(logComposer.getRequestLog(from: logData))
        }
    }
    
    public func xnLogger(logResponse logData: XNLogData) {
        
        if shouldLogResponse(logData: logData) {
            print(logComposer.getResponseLog(from: logData))
        }
    }
    
}
