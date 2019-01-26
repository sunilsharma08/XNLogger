//
//  RemoteLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class NLRemoteLogHandler: NSObject, NLLogHandler {
    
    private let ipAddress: String = "127.1.1.2"
    private let port: UInt = 443
    private let logComposer = LogComposer()
    
    public func logNetworkRequest(_ urlRequest: URLRequest) {
        
    }
    
    public func logNetworkResponse(for urlRequest: URLRequest, responseData: NLResponseData) {
        
    }
    
}
