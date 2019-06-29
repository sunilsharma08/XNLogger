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
    
    public func logNetworkRequest(_ urlRequest: URLRequest) {
        
        if isAllowed(urlRequest: urlRequest) {
            print(logComposer.getRequestLog(from: urlRequest))
        }
    }
    
    public func logNetworkResponse(for urlRequest: URLRequest, responseData: NLResponseData) {
        
        if isAllowed(urlRequest: urlRequest) {
            print(logComposer.getResponseLog(urlRequest: urlRequest, response: responseData))
        }
    }
    
}
