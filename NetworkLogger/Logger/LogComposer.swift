//
//  LogComposer.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

internal class LogComposer {
    
    let formatter: NLLogFormatter
    let dateFormatter = DateFormatter()
    
    init(logFormatter: NLLogFormatter) {
        self.formatter = logFormatter
        self.dateFormatter.dateFormat = "yyyy-MM-dd H:m:ss.SSSS"
    }
    
    func getResponseLog(from logData: NLLogData) ->  String {
        
        var responseStr = "\n\(getBoundry(for: "Response"))\n"
        responseStr += "\(getIdentifierString(logData.identifier))"
        responseStr += "\nResponse for Request\n\(logData.urlRequest.cURL)\n"
        
        if let metaData = logData.response {
            responseStr += "\n\(getBoundry(for: "Response Metadata"))\n\n"
            responseStr += getResponseMetaData(response: metaData) + "\n"
            responseStr += "\n\(getBoundry(for: "Response Metadata End"))\n"
        }
        
        if let error = logData.error {
            responseStr += "\n\(getBoundry(for: "Response Error"))\n\n"
            responseStr += error.localizedDescription + "\n"
            responseStr += "\n\(getBoundry(for: "Response Error End"))\n"
        }
        
        if let data = logData.receivedData, data.isEmpty == false {
            responseStr += "\n\(getBoundry(for: "Response Content"))\n\n"
            if formatter.prettyPrintJSON, let str = JSONUtils.shared.getJSONPrettyPrintORStringFrom(jsonData: data) {
                responseStr.append("\n\(str)")
            } else {
                responseStr.append("\n\(JSONUtils.shared.getStringFrom(data: data))")
            }
            responseStr += "\n\(getBoundry(for: "Response Content End"))\n"
        }
        
        responseStr += "\n\(getBoundry(for: "Response End"))"
        return responseStr
    }
    
    func getRequestLog(from logData: NLLogData) -> String {
        let urlRequest: URLRequest = logData.urlRequest
        var urlRequestStr = ""
        urlRequestStr += "\n\(getBoundry(for: "Request"))\n"
        urlRequestStr += "\nId: \(getIdentifierString(logData.identifier))"
        urlRequestStr += "\nURL: \(urlRequest.url?.absoluteString ?? "-")"
        if let port = urlRequest.url?.port {
            urlRequestStr += "\nPort: \(port)"
        }
        urlRequestStr += "\nMethod: \(urlRequest.httpMethod ?? "-")"
        if let headerFields = urlRequest.allHTTPHeaderFields, headerFields.isEmpty == false {
            urlRequestStr += "\n\nHeaders fields:"
            for (key, value) in headerFields {
                urlRequestStr.append("\n\(key) = \(value)")
            }
        }
        
        if let httpBody = urlRequest.httpBodyString(prettyPrint: true) {
            urlRequestStr.append("\n\nHttp Body:")
            urlRequestStr.append("\n\(httpBody)")
        }
        
        if formatter.showCurlWithReqst {
            urlRequestStr += "\nCURL: \(urlRequest.cURL)"
        }
        
        for metaInfo in formatter.showReqstMetaInfo {
            
            switch metaInfo {
            case .timeoutInterval:
                urlRequestStr += "\nTimeout interval: \(urlRequest.timeoutInterval)"
            case .cellularAccess:
                urlRequestStr += "\nMobile data access allowed: \(urlRequest.allowsCellularAccess)"
            case .cachePolicy:
                urlRequestStr += "\nCache policy: \(urlRequest.getCachePolicyName())"
            case .networkType:
                urlRequestStr += "\nNetwork service type: \(urlRequest.networkServiceType.rawValue)"
            case .httpPipeliningStatus:
                urlRequestStr += "\nHTTP Pipelining will be used: \(urlRequest.httpShouldUsePipelining)"
            case .cookieStatus:
                urlRequestStr += "\nCookies will be handled: \(urlRequest.httpShouldHandleCookies)"
            case .requestStartTime:
                if let startDate: Date = logData.startTime {
                    urlRequestStr += "\nStart time: \(dateFormatter.string(from: startDate))"
                }
            case .threadName:
                urlRequestStr += "\nThread: Coming soon..."
            }
        }
        
        urlRequestStr += "\n\n\(getBoundry(for: "Request End"))\n"
        
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
    
    func getIdentifierString(_ identifier: String) -> String {
        return "\(identifier) (Generated by NetworkLogger)"
    }
    
}
