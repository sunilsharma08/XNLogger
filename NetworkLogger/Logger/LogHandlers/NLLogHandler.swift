//
//  NLLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

/**
 Log handler protocol. All log handler must adopt this protocol.
 */
@objc public protocol NLLogHandler: class {
    
    @objc optional func networkLogger(logRequest logData: NLLogData)
    @objc optional func networkLogger(logResponse logData: NLLogData)
}

public enum NLLogHandlerType {
    
    case console
    case slack
    case remote
    case file
}

protocol NLRemoteLogger {
    
    func writeLog(urlRequest: URLRequest)
}

extension NLRemoteLogger {
    
    func writeLog(urlRequest: URLRequest) {
        guard let request = AppUtils.shared.createNLRequest(urlRequest)
        else { return }
        URLSession.shared.dataTask(with: request).resume()
    }
    
}
