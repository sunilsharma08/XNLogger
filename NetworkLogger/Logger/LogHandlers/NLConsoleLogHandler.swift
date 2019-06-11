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
    
    public func logNetworkRequest(_ urlRequest: URLRequest) {
        if self.filters.count > 0 {
            for filter in self.filters where filter.isAllowed(urlRequest: urlRequest) {
                print(logComposer.getRequestLog(from: urlRequest))
                break
            }
        }
        else {
            print(logComposer.getRequestLog(from: urlRequest))
        }
    }
    
    public func logNetworkResponse(for urlRequest: URLRequest, responseData: NLResponseData) {
        if self.filters.count > 0 {
            for filter in self.filters where filter.isAllowed(urlRequest: urlRequest) {
                print(logComposer.getResponseLog(urlRequest: urlRequest, response: responseData))
                break
            }
        } else {
            print(logComposer.getResponseLog(urlRequest: urlRequest, response: responseData))
        }
        
    }
    
}
