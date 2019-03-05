//
//  NLBaseLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 05/03/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public class NLBaseLogHandler: NSObject {
    
    private(set) var filters: [NLFilter] = []
    
    public func addFilters(_ filters: [NLFilter]) {
        self.filters.append(contentsOf: filters)
    }
    
    public func removeFilters(atIndex index: Int) {
        if index < self.filters.count {
            self.filters.remove(at: index)
        } else {
            debugPrint("Tried to remove filter at index \(index) which does not exist(index out of range).")
        }
    }
    
    public func removeAllFilters() {
        self.filters.removeAll()
    }
}
