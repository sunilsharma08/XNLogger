//
//  XNFilterManager.swift
//  XNLogger
//
//  Created by Sunil Sharma on 25/06/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

class XNFilterManager: @unchecked Sendable {

    // class will be usefull to keep some meta data about filter
    private class FilterData {
        var filters: [XNFilter] = []
    }

    private let lock = NSLock()
    private var schemeFilter: FilterData = FilterData()
    private var hostFilter: FilterData = FilterData()
    private var containsFilter: FilterData = FilterData()
    
    /**
     Return all types of filter.
     */
    func getFilters() -> [XNFilter] {
        lock.lock()
        defer { lock.unlock() }
        return schemeFilter.filters + hostFilter.filters + containsFilter.filters
    }
    
    func addFilters(_ filters: [XNFilter]) {
        lock.lock()
        defer { lock.unlock() }
        for filter in filters {
            _addFilter(filter)
        }
    }

    func addFilter(_ filter: XNFilter) {
        lock.lock()
        defer { lock.unlock() }
        _addFilter(filter)
    }

    private func _addFilter(_ filter: XNFilter) {
        //TODO: Before adding filter can be checked for duplicate.

        if let schemeFilter = filter as? XNSchemeFilter {
            self.schemeFilter.filters.append(schemeFilter)
        } else if let domainFilter = filter as? XNHostFilter {
            self.hostFilter.filters.append(domainFilter)
        } else if let containsFilter = filter as? XNContainsFilter {
            self.containsFilter.filters.append(containsFilter)
        }
    }
    
    func removeFilters(_ filters: [XNFilter]) {
        lock.lock()
        defer { lock.unlock() }
        for filter in filters {
            _removeFilter(filter)
        }
    }

    func removeFilter(_ filter: XNFilter) {
        lock.lock()
        defer { lock.unlock() }
        _removeFilter(filter)
    }

    private func _removeFilter(_ filter: XNFilter) {
        if let schemeFilter = filter as? XNSchemeFilter {
            self.schemeFilter.filters = self.schemeFilter.filters.filter { (item) -> Bool in
                return item !== schemeFilter
            }
        }
        else if let domainFilter = filter as? XNHostFilter {
            self.hostFilter.filters = self.hostFilter.filters.filter { (item) -> Bool in
                return item !== domainFilter
            }
        }
        else if let containsFilter = filter as? XNContainsFilter {
            self.containsFilter.filters = self.containsFilter.filters.filter { (item) -> Bool in
                return item !== containsFilter
            }
        }
    }
    
    /**
     Clear all types of filters.
     */
    func removeAllFilters() {
        lock.lock()
        defer { lock.unlock() }
        self.schemeFilter.filters.removeAll()
        self.hostFilter.filters.removeAll()
        self.containsFilter.filters.removeAll()
    }
    
    func isAllowed(urlRequest: URLRequest) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        // When all filters are empty, it is assumed that all urls are allowed
        if self.schemeFilter.filters.isEmpty && self.hostFilter.filters.isEmpty && self.containsFilter.filters.isEmpty {
            return true
        }

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
        
        // Incase filter is empty it is assumed that filter allows request.
        if filterData.filters.isEmpty {
            return true
        }
        
        var isFilterAllowed: Bool = false
        for filter in filterData.filters {
            if filter.isAllowed(urlRequest: urlRequest) {
                isFilterAllowed = true
                break
            }
        }
        return isFilterAllowed
    }
}
