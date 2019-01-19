//
//  ConsoleLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class NLConsoleLogHandler: NSObject, NLLogHandler {
    
    private var filters: [NLFilter]?
    private let logComposer = LogComposer()
    
    init(filters: [NLFilter]?) {
        self.filters = filters
    }
    
    public func logNetworkRequest(_ urlRequest: URLRequest) {
        
        if let filters = self.filters {
            for filter in filters where filter.shouldLog(urlRequest: urlRequest) {
                print(logComposer.getRequestLog(from: urlRequest))
            }
        }
        else {
            print(logComposer.getRequestLog(from: urlRequest))
        }
    }
    
    public func logNetworkResponse(for urlRequest: URLRequest, responseData: NLResponseData) {
        
    }
    
}
