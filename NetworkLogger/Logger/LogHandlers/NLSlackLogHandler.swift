//
//  SlackLogHandler.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 10/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

public class NLSlackLogHandler: NSObject, NLLogHandler {
    
    private let slackUserInfo: NLSlackUser
    private let logComposer = LogComposer()
    
    init(slackUserInfo: NLSlackUser) {
        self.slackUserInfo = slackUserInfo
    }
    
    public func logNetworkRequest(_ urlRequest: URLRequest) {
        
        URLSession.shared.interceptableDataTask(with: generateSlackPayloadFromRequest(originalRequest: urlRequest)) { (data, response, error) in
        }.resume()
        
    }
    
    public func logNetworkResponse(for urlRequest: URLRequest, responseData: NLResponseData) {
        
    }
    
    
    func generateSlackForwardingRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest()
        request.url = URL(string: "https://slack.com/api/chat.postMessage")
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(self.slackUserInfo.token)"
        ]
        request.httpMethod = "POST"
        return request
    }
    
    func generateForwardingJsonBody() -> [String: String] {
        let json: [String: String] = [
            "channel": self.slackUserInfo.channel,
            "username": self.slackUserInfo.username,
            "pretty": "1",
            ]
        return json
    }
    
    func generateSlackPayloadFromRequest(originalRequest: URLRequest) -> URLRequest{
        let request = self.generateSlackForwardingRequest()
        var json = self.generateForwardingJsonBody()
        
        let bundleName = Bundle.main.infoDictionary!["CFBundleName"] as? String ?? ""
        let text: String  = logComposer.getRequestLog(from: originalRequest)
        json["text"] = "```[\(bundleName)] \(text)```"
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        return request as URLRequest
    }
    
}
