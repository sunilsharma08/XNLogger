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
        if shouldLog(request) {
            NetworkLogger.shared.logRequest(request)
            return true
        } else {
            return false
        }
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
    
    fileprivate class func shouldLog(_ request: URLRequest) -> Bool {
        
        if let scheme = request.url?.scheme?.lowercased(),
            scheme == NLSchemeType.http.rawValue || scheme == NLSchemeType.https.rawValue {
            
            if NetworkLogger.shared.filters.isEmpty {
                return true
            }
            for skipUrls in NetworkLogger.shared.filters {
                if skipUrls.isAllowed(urlRequest: request) {
                    return true
                }
            }
            return false
        }
        else {
            return false
        }
    }
    
}
