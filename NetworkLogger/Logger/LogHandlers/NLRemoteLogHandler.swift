//
//  RemoteLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class NLRemoteLogHandler: NSObject, NLLogHandler, NLRemoteLogger {
    
    private let host: String
    private let port: UInt
    private let logComposer = LogComposer()
    
    public class func create(host: String, port: UInt) -> NLRemoteLogHandler {
        return NLRemoteLogHandler(host: host, port: port)
    }
    
    init(host: String, port: UInt) {
        self.host = host
        self.port = port
    }
    
    public func logNetworkRequest(_ urlRequest: URLRequest) {
        
    }
    
    public func logNetworkResponse(for urlRequest: URLRequest, responseData: NLResponseData) {
        
    }
    
}
