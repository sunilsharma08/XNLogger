//
//  NLResponseData.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 18/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public struct NLResponseData {
    
    let responseHeader: URLResponse?
    let responseData: Data?
    let error: Error?
    
    init(response: URLResponse? = nil, responseData: Data? = nil, error: Error? = nil) {
        self.responseHeader = response
        self.responseData = responseData
        self.error = error
    }
}
