//
//  NLUILogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 23/08/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

@objc public class NLUILogHandler: NLBaseLogHandler, NLLogHandler {
    
    private var logComposer: LogComposer!
    weak var delegate: NLUILogListDelegate?
    
    public class func create() -> NLUILogHandler {
        let instance: NLUILogHandler = NLUILogHandler()
        instance.logComposer = LogComposer(logFormatter: instance.logFormatter)
        return instance
    }
    
    public func networkLogger(logRequest logData: NLLogData) {
        delegate?.receivedLogData(logData, isResponse: false)
    }
    
    public func networkLogger(logResponse logData: NLLogData) {
        delegate?.receivedLogData(logData, isResponse: true)
    }
    
}
