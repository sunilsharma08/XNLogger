//
//  NLFilterManager.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 25/06/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

class NLFilterManager {
    
    private class FilterData {
        var filters: [NLFilter] = []
        var invert: Bool = false
    }
    
    private var schemeFilter: FilterData = FilterData()
    private var hostFilter: FilterData = FilterData()
    private var containsFilter: FilterData = FilterData()
    
    func getFilters() -> [NLFilter] {
        return schemeFilter.filters + hostFilter.filters + containsFilter.filters
    }
    
    func addFilters(_ filters: [NLFilter]) {
        for filter in filters {
            addFilter(filter)
        }
    }
    
    func addFilter(_ filter: NLFilter) {
        //TODO: Before adding filter can be checked for duplicate.
        
        if let schemeFilter = filter as? NLSchemeFilter {
            self.schemeFilter.filters.append(schemeFilter)
        } else if let domainFilter = filter as? NLHostFilter {
            self.hostFilter.filters.append(domainFilter)
        } else if let containsFilter = filter as? NLContainsFilter {
            self.containsFilter.filters.append(containsFilter)
        }
    }
    
    func removeFilters(_ filters: [NLFilter]) {
        for filter in filters {
            removeFilter(filter)
        }
    }
    
    func removeFilter(_ filter: NLFilter) {
        if let schemeFilter = filter as? NLSchemeFilter {
            self.schemeFilter.filters = self.schemeFilter.filters.filter { (item) -> Bool in
                return item !== schemeFilter
            }
        }
        else if let domainFilter = filter as? NLHostFilter {
            self.hostFilter.filters = self.hostFilter.filters.filter { (item) -> Bool in
                return item !== domainFilter
            }
        }
        else if let containsFilter = filter as? NLContainsFilter {
            self.containsFilter.filters = self.containsFilter.filters.filter { (item) -> Bool in
                return item !== containsFilter
            }
        }
    }
    
    func removeAllFilters() {
        self.schemeFilter.filters.removeAll()
        self.hostFilter.filters.removeAll()
        self.containsFilter.filters.removeAll()
    }
    
    func isAllowed(urlRequest: URLRequest) -> Bool {
        // When all filters are empty, it is assumed that all urls are allowed
        if self.schemeFilter.filters.isEmpty && self.hostFilter.filters.isEmpty && self.containsFilter.filters.isEmpty {
            return true
        }
        
        /**
         Check each filter type with priority.
         Filter priority order from highest to lowest are as:
         Scheme - Highest
         Host
         Contains - Lowest
         */
        if isFilter(self.schemeFilter, allowUrlRequest: urlRequest) == false {
            return false
        }
        
        if isFilter(self.hostFilter, allowUrlRequest: urlRequest) == false {
            return false
        }
        
        if isFilter(self.containsFilter, allowUrlRequest: urlRequest) == false {
            return false
        }
        
        return true
    }
    
    /**
     Check whether given URLRequest scheme is allowed to log or not.
     */
    private func isFilter(_ filterData: FilterData, allowUrlRequest urlRequest: URLRequest) -> Bool {
        
        // Incase Scheme filter is empty it is assumed that all scheme is allowed.
        if filterData.filters.isEmpty {
            return true
        }
        
        var isFilterAllowed: Bool = false
        for filter in filterData.filters {
            /**
            It performs XOR operation means for same result log in not
            allowed whereas for opposite allowed.
             
             Case 1: When isAllowed return true mean given url contains the current filter value and at that time if filter invert is false means this url should be logged.
             Case 2: When isAllowed return false and invert filter is false then it should not be allowed to log.
             Case 3: When isAllowed return true and invert filter is true then it should not be allowed to log.
             Case 4: When isAllowed return false and invert filter is true then it should be allowed to log.
            */
            if filter.isAllowed(urlRequest: urlRequest) != filterData.invert {
                isFilterAllowed = true
                break
            }
        }
        return isFilterAllowed
    }
    
    // MARK: Filter invert and revert methods
    func invert(filterType: NLFilterType) {
        update(filterType: filterType, toInvertMode: true)
    }
    
    func revert(filterType: NLFilterType) {
        update(filterType: filterType, toInvertMode: false)
    }
    
    func update(filterType: NLFilterType, toInvertMode state: Bool) {
        switch filterType {
        case .scheme:
            self.schemeFilter.invert = state
        case .host:
            self.hostFilter.invert = state
        case .contains:
            self.containsFilter.invert = state
        }
    }
}
