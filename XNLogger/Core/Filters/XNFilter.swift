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
    
    var invert: Bool { get set }
    func isAllowed(urlRequest: URLRequest) -> Bool
}

@objc public class XNSchemeFilter: NSObject, XNFilter {
    
    private let scheme: String
    public var invert: Bool = false
    
    @objc public init(scheme: String) {
        self.scheme = scheme.lowercased()
    }
    
    @objc public init(scheme: String, invert: Bool) {
        self.scheme = scheme.lowercased()
        self.invert = invert
    }
    
    public func isAllowed(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let scheme = urlRequest.url?.scheme,
            scheme.lowercased() == self.scheme {
            status = true
        }
        if invert {
            return !status
        }
        return status
    }
}

@objc public class XNHostFilter: NSObject, XNFilter {
    
    private let host: String
    public var invert: Bool = false
    
    @objc public init(host: String) {
        self.host = host.lowercased()
    }
    
    @objc public init(host: String, invert: Bool) {
        self.host = host.lowercased()
        self.invert = invert
    }
    
    public func isAllowed(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let host = urlRequest.url?.host,
           host.lowercased() == self.host {
            status = true
        }
        if invert {
            return !status
        }
        return status
    }
}

@objc public class XNContainsFilter: NSObject, XNFilter {
    
    private let filterString: String
    public var invert: Bool = false
    
    @objc public init(filterString: String) {
        self.filterString = filterString.lowercased()
    }
    
    @objc public init(filterString: String, invert: Bool) {
        self.filterString = filterString.lowercased()
        self.invert = invert
    }
    
    public func isAllowed(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let url = urlRequest.url?.absoluteString.lowercased(),
            url.contains(filterString){
            status = true
        }
        if invert {
            return !status
        }
        return status
    }
}


