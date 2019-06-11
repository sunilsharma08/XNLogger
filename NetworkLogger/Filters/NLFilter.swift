//
//  NLFilter.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public enum NLFilterType {
    
    case scheme(NLSchemeType)
    case domain(String)
    case contains(String)
    
}

public enum NLSchemeType: String {
    case http
    case https
}

public protocol NLFilter: class {
    
    var invert: Bool { get set }
    func isAllowed(urlRequest: URLRequest) -> Bool
    
}

extension NLFilter {
    
    func updateStatus(_ status: Bool) -> Bool {
        if invert {
            return !status
        } else {
            return status
        }
    }
}

class NLSchemeFilter: NLFilter {
    
    private let scheme: NLSchemeType
    public var invert: Bool = false
    
    init(scheme: NLSchemeType) {
        self.scheme = scheme
    }
    
    public func isAllowed(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let scheme = urlRequest.url?.scheme,
            scheme.lowercased() == self.scheme.rawValue {
            status = true
        }
        
        return updateStatus(status)
    }
    
}

class NLDomainFilter: NLFilter {
    
    private let domain: String
    public var invert: Bool = false
    
    init(domain: String) {
        self.domain = domain.lowercased()
    }
    
    public func isAllowed(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let host = urlRequest.url?.host,
           host.lowercased() == self.domain {
            status = true
        }
        
        return updateStatus(status)
    }
    
}

class NLContainsFilter: NLFilter {
    
    private let filterString: String
    public var invert: Bool = false
    
    init(filterString: String) {
        self.filterString = filterString.lowercased()
    }
    
    func isAllowed(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let url = urlRequest.url?.absoluteString.lowercased(),
            url.contains(filterString){
            status = true
        }
        
        return updateStatus(status)
    }
    
}


