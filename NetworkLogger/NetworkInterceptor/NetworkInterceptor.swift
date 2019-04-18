//
//  NetworkInterceptor.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 03/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

internal class NetworkInterceptor: NSObject {
    
    /**
     Setup and start logging network calls
     */
    func startInterceptingNetwork() {
            swizzleDataTask()
    }
    
    /**
     Stop intercepting network calls and revert back changes made to
     intercept network calls.
     */
    func stopInterceptingNetwork() {
        // Need logic to confirm revert back
        swizzleDataTask()
    }
    
    /**
     Swizzle original Data task method with Interceptable Data task method.
     */
    func swizzleDataTask() {
        
        let sessionInstance = URLSession(configuration: .default)
        guard let urlSessionClass:AnyClass = object_getClass(sessionInstance) else {
            debugPrint("Failed to get URLSession Class")
            return
        }
        
        let dataTaskSel = #selector((URLSession.dataTask(with:completionHandler:)) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        
        let interceptableDataTaskSel = #selector((URLSession.interceptableDataTask(with:completionHandler:)) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)
        
        if let originalMethod = class_getInstanceMethod(urlSessionClass, dataTaskSel),
            let interceptableMethod = class_getInstanceMethod(URLSession.self, interceptableDataTaskSel) {
            method_exchangeImplementations(originalMethod, interceptableMethod)
        }
        else {
            debugPrint("Failed to get data task method instance")
        }
    }
}

/**
 Implement interceptable data task method.
 */
internal extension URLSession {
    
    @objc func interceptableDataTask(with request: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) -> URLSessionDataTask {
        print("delegate = %@",delegate)
        NetworkLogger.shared.logRequest(request)
        
        let sessionDataTask = self.interceptableDataTask(with: request) { (data, response, error) in
            
            let responseData = NLResponseData(response: response, responseData: data, error: error)
            NetworkLogger.shared.logResponse(for: request, responseData: responseData)
            
            completionHandler?(data, response, error)
        }
        return sessionDataTask
    }
    
}

