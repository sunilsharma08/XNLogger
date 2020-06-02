//
//  XNUILogHandler.swift
//  XNLogger
//
//  Created by Sunil Sharma on 23/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

@objc public class XNUILogHandler: XNBaseLogHandler, XNLogHandler {
    
    private var logComposer: XNLogComposer!
    weak var delegate: XNUILogDataDelegate?
    
    public class func create() -> XNUILogHandler {
        let instance: XNUILogHandler = XNUILogHandler()
        instance.logFormatter.logUnreadableRespBody = true
        instance.logFormatter.logUnreadableReqstBody = true
        instance.logComposer = XNLogComposer(logFormatter: instance.logFormatter)
        return instance
    }
    
    private override init() {
        super.init()
    }
    
    public func xnLogger(logRequest logData: XNLogData) {
        if shouldLogRequest(logData: logData) || logFormatter.showReqstWithResp {
            delegate?.receivedLogData(logData, isResponse: false)
        }
    }
    
    public func xnLogger(logResponse logData: XNLogData) {
        if shouldLogResponse(logData: logData) {
            delegate?.receivedLogData(logData, isResponse: true)
        }
    }
    
}
