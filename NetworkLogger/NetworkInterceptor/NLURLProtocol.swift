//
//  NLURLProtocol.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 14/04/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

open class NLURLProtocol: URLProtocol {
    
    open override class func canInit(with request: URLRequest) -> Bool {
        debugPrint(#function)
        NetworkLogger.shared.logRequest(request)
        return canServeRequest(request)
    }
    
    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    open override func startLoading() {
        print(#function)
    }
    
    open override func stopLoading() {
        print(#function)
    }
    
}

// Helper private methods
fileprivate extension NLURLProtocol {
    
    fileprivate class func canServeRequest(_ request: URLRequest) -> Bool {
        
        return true
    }
    
}
