//
//  RemoteLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class NLRemoteLogHandler: NLBaseLogHandler, NLLogHandler, NLRemoteLogger {
    
    private let urlRequest: URLRequest
    private let logComposer = LogComposer()
    
    public class func create(urlRequest: URLRequest) -> NLRemoteLogHandler {
        return NLRemoteLogHandler(urlRequest: urlRequest)
    }
    
    init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
    public func logNetworkRequest(_ urlRequest: URLRequest) {
        if isAllowed(urlRequest: urlRequest) {
            let message = logComposer.getRequestLog(from: urlRequest)
            let remoteRequest = appendLogInHttpBody(urlRequest, message: message)
            
            self.writeLog(urlRequest: remoteRequest)
        }
    }
    
    public func logNetworkResponse(for urlRequest: URLRequest, responseData: NLResponseData) {
        if isAllowed(urlRequest: urlRequest) {
            let message = logComposer.getResponseLog(urlRequest: urlRequest, response: responseData)
            let remoteRequest = appendLogInHttpBody(urlRequest, message: message)
            
            self.writeLog(urlRequest: remoteRequest)
        }
    }
    
    private func appendLogInHttpBody(_ request: URLRequest, message: String) -> URLRequest {
        var urlRequest = request
        var bodyJson: [String: Any] = [:]
        if let httpData = urlRequest.httpBody,
            let json = JSONUtils.shared.getDictionaryFrom(jsonData: httpData) {
            bodyJson = json
        }
        
        bodyJson["nl-log-msg"] = message
        let jsonData = try? JSONSerialization.data(withJSONObject: bodyJson)
        urlRequest.httpBody = jsonData
        return urlRequest as URLRequest
    }
    
}
