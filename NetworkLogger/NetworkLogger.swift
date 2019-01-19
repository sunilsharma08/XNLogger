//
//  NetworkLogger.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 16/12/18.
//  Copyright © 2018 Sunil Sharma. All rights reserved.
//

import Foundation

@objc public class NetworkLogger: NSObject {
    
    @objc public static let shared = NetworkLogger()
    private let networkInterceptor = NetworkInterceptor()
    private var handlers:[NLLogHandler] = []
    
    override private init() {}
    
    public func startLogging() {
        print("Started logging all network traffic")
        networkInterceptor.startInterceptingNetwork()
    }
    
    public func stopLogging() {
        print("Stopped logging all network traffic")
        networkInterceptor.stopInterceptingNetwork()
    }
    
    public func addHandler(_ handler: NLLogHandler) {
        self.handlers.append(handler)
    }
    
    public func addHandlers(_ handlers: [NLLogHandler]) {
        self.handlers.append(contentsOf: handlers)
    }
    
    func logResponse(_ responseData: NLResponseData) {
        
//        if let error = error {
//            print("Error")
//            print(error.localizedDescription)
//            return
//        }
//        guard let data = data,
//            let response = response as? HTTPURLResponse
//            else { return }
//        print("Response header")
//        print(response)
//        print("Response")
//        print(JSONUtils().getJsonStringFrom(jsonData: data))
        
    }
    
    func logRequest(request: URLRequest) {
        print("Request")
        print(request)
    }
}
