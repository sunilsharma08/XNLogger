//
//  LogComposer.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

internal class LogComposer {
    
    func getResponseLog(from responseData: Data) ->  String {
        return JSONUtils().getJsonStringFrom(jsonData: responseData)
    }
    
    func getResponseHeaderLog(from response:URLResponse) -> String {
        return response.debugDescription
    }
    
    func getRequestLog(from urlRequest: URLRequest) -> String {
        return urlRequest.debugDescription
    }
    
    
    
}
