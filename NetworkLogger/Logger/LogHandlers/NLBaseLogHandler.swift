//
//  NLBaseLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 05/03/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public class NLBaseLogHandler: NSObject {
    
    private var filterManager: NLFilterManager = NLFilterManager()
    
    public func addFilters(_ filters: [NLFilter]) {
        self.filterManager.addFilters(filters)
    }
    
    public func removeAllFilters() {
        self.filterManager.removeAllFilters()
    }
    
    public func isAllowed(urlRequest: URLRequest) -> Bool {
        return filterManager.isAllowed(urlRequest: urlRequest)
    }
}
