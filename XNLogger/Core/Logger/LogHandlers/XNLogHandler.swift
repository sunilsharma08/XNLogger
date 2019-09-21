//
//  XNLogHandler.swift
//  XNLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

/**
 Log handler protocol. All log handler must adopt this protocol.
 */
@objc public protocol XNLogHandler: class {
    
    @objc optional func xnLogger(logRequest logData: XNLogData)
    @objc optional func xnLogger(logResponse logData: XNLogData)
}

public enum XNLogHandlerType {
    
    case console
    case slack
    case remote
    case file
}

protocol XNRemoteLogger {
    
    func writeLog(urlRequest: URLRequest)
}

extension XNRemoteLogger {
    
    func writeLog(urlRequest: URLRequest) {
        guard let request = XNAppUtils.shared.createNLRequest(urlRequest)
        else { return }
        URLSession.shared.dataTask(with: request).resume()
    }
    
}
