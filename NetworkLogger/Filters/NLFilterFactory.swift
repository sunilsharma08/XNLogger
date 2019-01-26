//
//  NLFilterFactory.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 26/01/19.
//

import Foundation

public class NLFilterFactory: NSObject {
    
    public func filter(_ filterType: NLFilterType) -> NLFilter {
        
        switch filterType {
        case .scheme(let scheme):
            return NLSchemeFilter(scheme: scheme)
        case .domain(let domain):
            return NLDomainFilter(domain: domain)
        case .contains(let filterStr):
            return NLContainsFilter(filterString: filterStr)
        }
        
    }
    
    public func exclude(_ filterType: NLFilterType) -> NLFilter {
        
        let filter: NLExcludableFilter
        
        switch filterType {
        case .scheme(let scheme):
            filter = NLSchemeFilter(scheme: scheme)
        case .domain(let domain):
            filter =  NLDomainFilter(domain: domain)
        case .contains(let filterStr):
            filter =  NLContainsFilter(filterString: filterStr)
        }
        filter.shouldExclude(true)
        return filter
    }
    
}
