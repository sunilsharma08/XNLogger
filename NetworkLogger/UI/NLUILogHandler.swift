//
//  NLUILogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 23/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

@objc public class NLUILogHandler: NLBaseLogHandler, NLLogHandler {
    
    private var logComposer: NLLogComposer!
    weak var delegate: NLUILogDataDelegate?
    
    public class func create() -> NLUILogHandler {
        let instance: NLUILogHandler = NLUILogHandler()
        instance.logComposer = NLLogComposer(logFormatter: instance.logFormatter)
        return instance
    }
    
    public func networkLogger(logRequest logData: NLLogData) {
        if shouldLogRequest(logData: logData) || logFormatter.showReqstWithResp {
            delegate?.receivedLogData(logData, isResponse: false)
        }
    }
    
    public func networkLogger(logResponse logData: NLLogData) {
        if shouldLogResponse(logData: logData) {
            delegate?.receivedLogData(logData, isResponse: true)
        }
    }
    
}
