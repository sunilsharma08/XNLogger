//
//  NLFilter.swift
//  NetworkLogger
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
public enum NLFilterType {
    case scheme     // http or https
    case host       // www.example.com
    case contains   // any string in url
    
    func create(filterString: String) ->  NLFilter {
        switch self {
        case .scheme:
            return NLSchemeFilter(scheme: filterString)
        case .host:
            return NLHostFilter(host: filterString)
        case .contains:
            return NLContainsFilter(filterString: filterString)
        }
    }
}

public protocol NLFilter: class {
    
    func isAllowed(urlRequest: URLRequest) -> Bool
}

class NLSchemeFilter: NLFilter {
    
    private let scheme: String
    
    init(scheme: String) {
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

class NLHostFilter: NLFilter {
    
    private let host: String
    
    init(host: String) {
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

class NLContainsFilter: NLFilter {
    
    private let filterString: String
    
    init(filterString: String) {
        self.filterString = filterString.lowercased()
    }
    
    func isAllowed(urlRequest: URLRequest) -> Bool {
        
        var status: Bool = false
        
        if let url = urlRequest.url?.absoluteString.lowercased(),
            url.contains(filterString){
            status = true
        }
        
        return status
    }
}


