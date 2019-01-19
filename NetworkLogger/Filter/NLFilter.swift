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
    
    public func filter() -> NLFilter {
        
        switch self {
        case .scheme(let scheme):
            return NLSchemeFilter(scheme: scheme)
        case .domain(let domain):
            return NLDomainFilter(domain: domain)
        case .contains(let filterStr):
            return NLContainsFilter(filterString: filterStr)
        }
    }
    
}

public protocol NLFilter {
    
    func shouldLog(urlRequest: URLRequest) -> Bool
    
}

public class NLSchemeFilter: NLFilter {
    
    private let scheme: String
    
    init(scheme: String) {
        self.scheme = scheme
    }
    
    public func shouldLog(urlRequest: URLRequest) -> Bool {
        // Need to add logic
        return true
    }
    
}

public class NLDomainFilter: NLFilter {
    
    let domain: String
    
    init(domain: String) {
        self.domain = domain
    }
    
    public func shouldLog(urlRequest: URLRequest) -> Bool {
        return true
    }
    
}

public class NLContainsFilter: NLFilter {
    
    let filterString: String
    
    init(filterString: String) {
        self.filterString = filterString
    }
    
    public func shouldLog(urlRequest: URLRequest) -> Bool {
        return true
    }
    
}


