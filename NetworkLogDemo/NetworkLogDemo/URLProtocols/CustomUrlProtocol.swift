//
//  CustomUrl.swift
//  NetworkLogDemo
//
//  Created by Sunil Sharma on 17/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import Foundation

open class CustomUrlProtocol: URLProtocol {
    
    override open class func canInit(with request: URLRequest) -> Bool {
        print("\(String(describing: self)):\(#function) => \(request.url?.absoluteString ?? "N/A")")
        return false
    }
    
    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        print("\(String(describing: self)):\(#function) => \(request.allHTTPHeaderFields ?? [:])")
        
        return request
    }
    
    override open func startLoading() {
        print("Started loading data")
    }
    
    override open func stopLoading() {
        print("Stopped loading data")
    }
    
}
