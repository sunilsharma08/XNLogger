//
//  NLFilterFactory.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 26/01/19.
//

import Foundation

public class NLFilterFactory: NSObject {
    
    public func filter(_ filterType: NLFilterType) -> NLFilter {
        
        return createFilter(filterType)
    }
    
    public func exclude(_ filterType: NLFilterType) -> NLFilter {
        
        let filter: NLFilter = createFilter(filterType)
        filter.invert = true
        return filter
    }
    
    private func createFilter(_ filterType: NLFilterType) -> NLFilter {
        switch filterType {
        case .scheme(let scheme):
            return NLSchemeFilter(scheme: scheme)
        case .domain(let domain):
            return NLDomainFilter(domain: domain)
        case .contains(let filterStr):
            return NLContainsFilter(filterString: filterStr)
        }
    }
    
}
