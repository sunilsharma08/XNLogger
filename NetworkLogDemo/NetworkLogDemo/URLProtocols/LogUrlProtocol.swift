//
//  LogUrlProtocol.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 14/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import Foundation

class LogUrlProtocol: URLProtocol {
    
    open override class func canInit(with request: URLRequest) -> Bool {
        print("Log URL \(request.url?.absoluteString ?? "")")
        return false
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {}
    
    override func stopLoading() {}
    
}
