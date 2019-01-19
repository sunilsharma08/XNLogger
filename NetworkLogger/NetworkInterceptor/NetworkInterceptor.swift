//
//  NetworkInterceptor.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 03/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

@objc internal class NetworkInterceptor: NSObject {
    
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
private extension URLSession {
    
    @objc func interceptableDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        NetworkLogger.shared.logRequest(request: request)
        
        let sessionDataTask = self.interceptableDataTask(with: request) { (data, response, error) in
            
            NetworkLogger.shared.logResponse(data: data, response: response, error: error)
            completionHandler(data,response,error)
            
        }
        return sessionDataTask
    }
    
}

