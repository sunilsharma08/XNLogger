//
//  AppUtils.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 01/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

class AppUtils {
    
    static let shared: AppUtils = AppUtils()
    static private var logIdentifier: UInt64 = 0
    
    private init() {}
    
    /**
     Create URLRequest which skip Network Logger
     */
    func createNLRequest(_ request: URLRequest) -> URLRequest? {
        let mutableURLRequest = request.getNSMutableURLRequest()
        mutableURLRequest?.setNLFlag(value: true)
        if let urlRequest = mutableURLRequest {
            return urlRequest as URLRequest
        } else {
            return nil
        }
    }
    
    func getLogIdentifier() -> String {
        return "\(AppUtils.logIdentifier)"
    }
    
    func nextLogIdentifier() -> String {
        AppUtils.logIdentifier += 1
        return "\(AppUtils.logIdentifier)"
    }
}
