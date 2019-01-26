//
//  LogComposer.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

internal class LogComposer {
    
    func getResponseLog(urlRequest: URLRequest, response: NLResponseData) ->  String {
        
        var responseStr = "\n\(getBoundry(for: "Response"))\n"
        responseStr += "\nResponse for Request\n\(urlRequest.cURL)\n"
        let jsonUtils = JSONUtils()
        
        if let metaData = response.responseHeader {
            responseStr += "\n\(getBoundry(for: "Response Metadata"))\n\n"
            responseStr += getResponseMetaData(response: metaData) + "\n"
            responseStr += "\n\(getBoundry(for: "Response Metadata End"))\n"
        }
        
        if let error = response.error {
            responseStr += "\n\(getBoundry(for: "Response Error"))\n\n"
            responseStr += error.localizedDescription + "\n"
            responseStr += "\n\(getBoundry(for: "Response Error End"))\n"
        }
        
        if let data = response.responseData {
            responseStr += "\n\(getBoundry(for: "Response Content"))\n\n"
            responseStr += jsonUtils.getJsonStringFrom(jsonData: data) + "\n"
            responseStr += "\n\(getBoundry(for: "Response Content End"))\n"
        }
        
        responseStr += "\n\(getBoundry(for: "Response End"))"
        return responseStr
    }
    
    func getRequestLog(from urlRequest: URLRequest) -> String {
        var urlRequestStr = ""
        
        urlRequestStr += "\n\(getBoundry(for: "Request"))\n\n"
        urlRequestStr += urlRequest.cURL + "\n"
        if let port = urlRequest.url?.port {
            urlRequestStr += "\nPort = \(port)"
        }
        urlRequestStr += "\nRequest Properties\n"
        urlRequestStr += "\nTimeout interval = \(urlRequest.timeoutInterval)"
        urlRequestStr += "\nMobile data access allowed = \(urlRequest.allowsCellularAccess)"
        urlRequestStr += "\nCache policy = \(urlRequest.cachePolicy)"
        urlRequestStr += "\nNetwork service type = \(urlRequest.networkServiceType)"
        urlRequestStr += "\nCookies will be handled = \(urlRequest.httpShouldHandleCookies)"
        urlRequestStr += "\nHTTP Pipelining will be used = \(urlRequest.httpShouldUsePipelining)"
        urlRequestStr += "\n\n\(getBoundry(for: "Request End"))"
        
        return urlRequestStr
    }
    
    private func getBoundry(for message: String) -> String {
        return "====== \(message) ======"
    }
    
    func getResponseMetaData(response: URLResponse) -> String {
        var responseStr = ""
        responseStr += "\nURL => \(response.url?.absoluteString ?? "Nil")"
        if let port = response.url?.port {
            responseStr += "\nPort => \(port)"
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            responseStr += "\nStatus Code => \(httpResponse.statusCode)"
            responseStr += "\nStatus Code description => \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
        }
        
        responseStr += "\nMime type => \(response.mimeType ?? "Nil")"
        responseStr += "\nExpected content length => \(response.expectedContentLength)"
        responseStr += "\nText encoding name => \(response.textEncodingName ?? "Nil")"
        responseStr += "\nSuggested file name => \(response.suggestedFilename ?? "Nil")"
        
        if let httpResponse = response as? HTTPURLResponse {
            responseStr += "\n\nHeaders fields\n"
            for (key, value) in httpResponse.allHeaderFields {
                responseStr.append("\n\(key) => \(value)")
            }
        }
        
        return responseStr
    }
    
}
