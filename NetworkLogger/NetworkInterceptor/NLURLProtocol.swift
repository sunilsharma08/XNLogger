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
        print(#function)
        return canServeRequest(request)
    }
    
    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    open override func startLoading() {
        print(#function)
//        URLProtocol.setProperty("1", forKey: "NFXInternal", in: request)
        
//        let configuration = URLSessionConfiguration.default
//        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
//        let task = session
    }
    
    open override func stopLoading() {
        print(#function)
    }
    
}

// Helper private methods
private extension NLURLProtocol {
    
    fileprivate class func canServeRequest(_ request: URLRequest) -> Bool {
        
        if let url = request.url {
            if !(url.absoluteString.hasPrefix("http")) &&
               !(url.absoluteString.hasPrefix("https")) {
                return false
            }
        }
        
//        if URLProtocol.property(forKey: "NFXInternal", in: request) != nil {
//            return false
//        }
        
        return true
    }
    
}
