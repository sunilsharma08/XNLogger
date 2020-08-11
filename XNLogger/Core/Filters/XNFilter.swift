//
//  XNFilter.swift
//  XNLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

/**
 Filter priority order from highest to lowest are as:
 Scheme - Highest
 Host
 Contains - Lowest
 */
public enum XNFilterType {
    case scheme     // http or https
    case host       // www.example.com
    case contains   // any string in url
    
    func create(filterString: String) ->  XNFilter {
        switch self {
        case .scheme:
            return XNSchemeFilter(scheme: filterString)
        case .host:
            return XNHostFilter(host: filterString)
        case .contains:
            return XNContainsFilter(filterString: filterString)
        }
    }
}

@objc public protocol XNFilter: class {
    
    func isAllowed(urlRequest: URLRequest) -> Bool
}

@objc public class XNSchemeFilter: NSObject, XNFilter {
    
    private let scheme: String
    
    @objc public init(scheme: String) {
        self.scheme = scheme.lowercased()
    }
    
    public func isAllowed(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let scheme = urlRequest.url?.scheme,
            scheme.lowercased() == self.scheme {
            status = true
        }
        
        return status
    }
}

@objc public class XNHostFilter: NSObject, XNFilter {
    
    private let host: String
    
    @objc public init(host: String) {
        self.host = host.lowercased()
    }
    
    public func isAllowed(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let host = urlRequest.url?.host,
           host.lowercased() == self.host {
            status = true
        }
        
        return status
    }
}

@objc public class XNContainsFilter: NSObject, XNFilter {
    
    private let filterString: String
    
    @objc public init(filterString: String) {
        self.filterString = filterString.lowercased()
    }
    
    public func isAllowed(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let url = urlRequest.url?.absoluteString.lowercased(),
            url.contains(filterString){
            status = true
        }
        
        return status
    }
}


