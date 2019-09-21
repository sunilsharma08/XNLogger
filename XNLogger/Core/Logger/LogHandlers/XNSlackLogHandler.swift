//
//  XNSlackLogHandler.swift
//  XNLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class XNSlackLogHandler: XNBaseLogHandler, XNLogHandler, XNRemoteLogger {
    
    private let webhookUrl: String
    private var logComposer: XNLogComposer!
    
    public class func create(webhookUrl: String) -> XNSlackLogHandler {
        let instance: XNSlackLogHandler = XNSlackLogHandler(webhookUrl: webhookUrl)
        instance.logComposer = XNLogComposer(logFormatter: instance.logFormatter)
        return instance
    }
    
    private init(webhookUrl: String) {
        self.webhookUrl = webhookUrl
    }
    
    public func xnLogger(logRequest logData: XNLogData) {
        
        if shouldLogRequest(logData: logData) {
            let message = logComposer.getRequestLog(from: logData)
            let slackRequest = getSlackRequest(forRequest: logData.urlRequest, message: message)
            
            self.writeLog(urlRequest: slackRequest)
        }
    }
    
    public func xnLogger(logResponse logData: XNLogData) {
        
        if shouldLogResponse(logData: logData) {
            let message = logComposer.getResponseLog(from: logData)
            let slackRequest = getSlackRequest(forRequest: logData.urlRequest, message: message)
            
            self.writeLog(urlRequest: slackRequest)
        }
    }
    
    func getSlackRequest(forRequest originalRequest: URLRequest, message: String) -> URLRequest {
        let request = self.createSlackRequest()
        var bodyJson: [String: Any] = [:]
        bodyJson["text"] = "```\(message)```"
        bodyJson["pretty"] = "1"
        bodyJson["mrkdwn"] = true
        let jsonData = try? JSONSerialization.data(withJSONObject: bodyJson)
        request.httpBody = jsonData
        return request as URLRequest
    }
    
    func createSlackRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest()
        request.url = URL(string: self.webhookUrl)
        
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        request.httpMethod = "POST"
        return request
    }
    
}
