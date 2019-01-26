//
//  NLFilter.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public enum NLFilterType {
    
    case scheme(String)
    case domain(String)
    case contains(String)
    
}

public protocol NLFilter {
    
    func shouldLog(urlRequest: URLRequest) -> Bool
    
}

protocol NLExcludableFilter: NLFilter {
    
    var shouldExclude: Bool {get}
    func shouldExclude(_ value: Bool)
    
    func updateStatus(_ status: Bool) -> Bool
    
}

extension NLExcludableFilter {
    
    func updateStatus(_ status: Bool) -> Bool {
        if shouldExclude {
            return !status
        } else {
            return status
        }
    }
}

class NLSchemeFilter: NLExcludableFilter {
    
    private let scheme: String
    internal var shouldExclude: Bool = false
    
    init(scheme: String) {
        self.scheme = scheme
    }
    
    func shouldExclude(_ value: Bool) {
        self.shouldExclude = value
    }
    
    public func shouldLog(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let scheme = urlRequest.url?.scheme,
            scheme == self.scheme {
            status = true
        }
        
        return updateStatus(status)
    }
    
}

class NLDomainFilter: NLExcludableFilter {
    
    private let domain: String
    internal var shouldExclude: Bool = false
    
    init(domain: String) {
        self.domain = domain
    }
    
    func shouldExclude(_ value: Bool) {
        self.shouldExclude = value
    }
    
    public func shouldLog(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let host = urlRequest.url?.host,
           host == self.domain {
            status = true
        }
        
        return updateStatus(status)
    }
    
}

class NLContainsFilter: NLExcludableFilter {
    
    private let filterString: String
    internal var shouldExclude: Bool = false
    
    init(filterString: String) {
        self.filterString = filterString
    }
    
    func shouldExclude(_ value: Bool) {
        self.shouldExclude = value
    }
    
    func shouldLog(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let url = urlRequest.url?.absoluteString,
            url.contains(filterString){
            status = true
        }
        
        return updateStatus(status)
    }
    
}


