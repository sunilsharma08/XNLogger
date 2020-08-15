//
//  XNRemoteLogHandler.swift
//  XNLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class XNRemoteLogHandler: XNBaseLogHandler, XNLogHandler, XNRemoteLogger {
    
    private let urlRequest: URLRequest
    private var logComposer: XNLogComposer!
    
    public class func create(urlRequest: URLRequest) -> XNRemoteLogHandler {
        let instance: XNRemoteLogHandler = XNRemoteLogHandler(urlRequest: urlRequest)
        instance.logComposer = XNLogComposer(logFormatter: instance.logFormatter)
        return instance
    }
    
    private init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
    public func xnLogger(logRequest logData: XNLogData) {
        if shouldLogRequest(logData: logData) {
            let message = logComposer.getRequestLog(from: logData)
            let remoteRequest = appendLogInHttpBody(urlRequest, message: message)
            
            self.writeLog(urlRequest: remoteRequest)
        }
    }
    
    public func xnLogger(logResponse logData: XNLogData) {
        if shouldLogResponse(logData: logData) {
            let message = logComposer.getResponseLog(from: logData)
            let remoteRequest = appendLogInHttpBody(urlRequest, message: message)
            
            self.writeLog(urlRequest: remoteRequest)
        }
    }
    
    private func appendLogInHttpBody(_ request: URLRequest, message: String) -> URLRequest {
        var urlRequest = request
        var bodyJson: [String: Any] = [:]
        // TODO: Handle different conditions like if httpStream and is exsiting is not dictionary
        if let httpData = urlRequest.httpBody,
            let json = XNJSONUtils().getDictionaryFrom(jsonData: httpData) {
            bodyJson = json
        }
        
        bodyJson["xn-log-msg"] = message
        let jsonData = try? JSONSerialization.data(withJSONObject: bodyJson)
        urlRequest.httpBody = jsonData
        return urlRequest as URLRequest
    }
    
}
