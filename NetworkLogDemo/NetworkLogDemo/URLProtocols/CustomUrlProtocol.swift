//
//  CustomUrl.swift
//  NetworkLogDemo
//
//  Created by Sunil Sharma on 17/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import Foundation

class CustomUrlProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        print("\(String(describing: self)):\(#function) => \(request.url?.absoluteString ?? "N/A")")
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        print("\(String(describing: self)):\(#function) => \(request.allHTTPHeaderFields ?? [:])")
        
        return request
    }
    
    override func startLoading() {
        print("Started loading data")
    }
    
    override func stopLoading() {
        print("Stopped loading data")
    }
    
}
