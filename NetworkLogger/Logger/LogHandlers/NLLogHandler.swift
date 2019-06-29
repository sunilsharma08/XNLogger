//
//  NLLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public protocol NLLogHandler: class {
    
    func logNetworkRequest(_ urlRequest: URLRequest)
    func logNetworkResponse(for urlRequest: URLRequest, responseData: NLResponseData)
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
        var request = urlRequest
        request.addValue("true", forHTTPHeaderField: AppConstants.LogRequestKey)
        URLSession.shared.dataTask(with: request).resume()
    }
    
}
