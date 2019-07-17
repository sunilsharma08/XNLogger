//
//  NLLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public protocol NLLogHandler: class {
    
    func logNetworkRequest(from logData: NLLogData)
    func logNetworkResponse(from logData: NLLogData)
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
