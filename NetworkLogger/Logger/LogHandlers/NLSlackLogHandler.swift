//
//  SlackLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class NLSlackLogHandler: NLBaseLogHandler, NLLogHandler, NLRemoteLogger {
    
    private let webhookUrl: String
    private let logComposer = LogComposer()
    
    init(webhookUrl: String) {
        self.webhookUrl = webhookUrl
    }
    
    public func logNetworkRequest(_ urlRequest: URLRequest) {
        func log() {
            let message = logComposer.getRequestLog(from: urlRequest)
            let slackRequest = getSlackRequest(forRequest: urlRequest, message: message)
            
            self.writeLog(urlRequest: slackRequest)
        }
        
        if self.filters.count > 0 {
            for filter in self.filters where filter.isAllowed(urlRequest: urlRequest) {
                log()
                break
            }
        }
        else {
            log()
        }
    }
    
    public func logNetworkResponse(for urlRequest: URLRequest, responseData: NLResponseData) {
        
        func log() {
            let message = logComposer.getResponseLog(urlRequest: urlRequest, response: responseData)
            let slackRequest = getSlackRequest(forRequest: urlRequest, message: message)
            
            self.writeLog(urlRequest: slackRequest)
        }
        
        if self.filters.count > 0 {
            for filter in self.filters where filter.isAllowed(urlRequest: urlRequest) {
                log()
                break
            }
        } else {
            log()
        }
    }
    
    func getSlackRequest(forRequest originalRequest:URLRequest, message: String) -> URLRequest {
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
