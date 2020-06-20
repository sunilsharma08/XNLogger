//
//  XNLogComposer.swift
//  XNLogger
//
//  Created by Sunil Sharma on 17/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

internal class XNLogComposer {
    
    let formatter: XNLogFormatter
    let dateFormatter = DateFormatter()
    
    init(logFormatter: XNLogFormatter) {
        self.formatter = logFormatter
        self.dateFormatter.dateFormat = "yyyy-MM-dd H:m:ss.SSSS"
    }
    
    func getRequestLog(from logData: XNLogData) -> String {
        return getRequestLog(from: logData, isResponseLog: false)
    }
    
    private func getRequestLog(from logData: XNLogData, isResponseLog: Bool) -> String {
        let urlRequest: URLRequest = logData.urlRequest
        var urlRequestStr = ""
        urlRequestStr += "\n\(getBoundry(for: "Request"))\n"
        urlRequestStr += "\nId: \(getIdentifierString(logData.identifier))"
        urlRequestStr += "\nURL: \(urlRequest.url?.absoluteString ?? "-")"
        if let port = urlRequest.url?.port {
            urlRequestStr += "\nPort: \(port)"
        }
        urlRequestStr += "\nMethod: \(urlRequest.httpMethod ?? "-")"
        urlRequestStr += "\n\nHeader fields:"
        if let headerFields = urlRequest.allHTTPHeaderFields, headerFields.isEmpty == false {
            for (key, value) in headerFields {
                urlRequestStr.append("\n\(key) = \(value)")
            }
        } else {
            urlRequestStr.append("\n\(getEmptyDataBoundary(for: "Header field is empty"))")
        }
        
        urlRequestStr.append("\n\nHttp body:")
        if let httpBody = urlRequest.httpBodyString(prettyPrint: formatter.prettyPrintJSON), httpBody.isEmpty == false {
            // Log HTTP body either `logUnreadableReqstBody` is true or when content is readable.
            if formatter.logUnreadableReqstBody || XNAppUtils.shared.isContentTypeReadable(logData.reqstContentMeta.contentType) {
                urlRequestStr.append("\n\(httpBody)\n")
            } else {
                urlRequestStr.append("\n\(logData.reqstContentMeta.contentType.getName()) data \n")
            }
        } else {
            urlRequestStr.append("\n\(getEmptyDataBoundary(for: "Http body is empty"))\n")
        }
        
        let showCurl: Bool = isResponseLog ? formatter.showCurlWithResp : formatter.showCurlWithReqst
        
        if showCurl {
            urlRequestStr += "\nCURL: \(urlRequest.cURL)"
        }
        
        let reqstMetaInfo: [XNRequestMetaInfo] = isResponseLog ? formatter.showReqstMetaInfoWithResp : formatter.showReqstMetaInfo
        
        for metaInfo in reqstMetaInfo {
            
            switch metaInfo {
            case .timeoutInterval:
                urlRequestStr += "\nTimeout interval: \(urlRequest.timeoutInterval)"
            case .cellularAccess:
                urlRequestStr += "\nMobile data access allowed: \(urlRequest.allowsCellularAccess)"
            case .cachePolicy:
                urlRequestStr += "\nCache policy: \(urlRequest.getCachePolicyName())"
            case .networkType:
                urlRequestStr += "\nNetwork service type: \(urlRequest.getNetworkTypeName())"
            case .httpPipeliningStatus:
                urlRequestStr += "\nHTTP Pipelining will be used: \(urlRequest.httpShouldUsePipelining)"
            case .cookieStatus:
                urlRequestStr += "\nCookies will be handled: \(urlRequest.httpShouldHandleCookies)"
            case .requestStartTime:
                if let startDate: Date = logData.startTime {
                    urlRequestStr += "\nStart time: \(dateFormatter.string(from: startDate))"
                }
            }
        }
        
        urlRequestStr += "\n\n\(getBoundry(for: "Request End"))\n"
        
        return urlRequestStr
    }
    
    func getResponseLog(from logData: XNLogData) ->  String {
        
        var responseStr: String = ""
        
        if formatter.showReqstWithResp {
            responseStr.append(getRequestLog(from: logData, isResponseLog: true))
        }
        
        responseStr += "\n\(getBoundry(for: "Response"))\n"
        responseStr += "\nId: \(getIdentifierString(logData.identifier))"
        
        // Response Meta Info
        if formatter.showRespMetaInfo.isEmpty == false {
            responseStr += "\nResponse Meta Info:"
            if let response = logData.response {
                
                for property in formatter.showRespMetaInfo {
                    
                    switch property {
                    case .statusCode:
                        if let httpResponse = response as? HTTPURLResponse {
                            responseStr += "\nStatus Code: \(httpResponse.statusCode)"
                        }
                    case .statusDescription:
                        if let httpResponse = response as? HTTPURLResponse {
                            responseStr += "\nStatus Code description: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                        }
                    case .mimeType:
                        responseStr += "\nMime type: \(response.mimeType ?? "-")"
                    case .textEncoding:
                        responseStr += "\nText encoding name: \(response.textEncodingName ?? "-")"
                    case .contentLength:
                        responseStr += "\nExpected content length: \(response.expectedContentLength)"
                    case .suggestedFileName:
                        responseStr += "\nSuggested file name: \(response.suggestedFilename ?? "-")"
                    case .headers:
                        if let httpResponse = response as? HTTPURLResponse,
                            httpResponse.allHeaderFields.isEmpty == false {
                            
                            responseStr += "\n\nResponse headers fields:"
                            for (key, value) in httpResponse.allHeaderFields {
                                responseStr.append("\n\(key) = \(value)")
                            }
                        }
                    case .requestStartTime:
                        if let startDate: Date = logData.startTime {
                            responseStr.append("\nStart time: \(dateFormatter.string(from: startDate))")
                        }
                    case .duration:
                        if let durationStr: String = logData.getDurationString() {
                            responseStr.append("\nDuration: " + durationStr)
                        } else {
                            responseStr.append("\nDuration: -")
                        }
                    }
                }
            } else {
                responseStr.append("\n\(getEmptyDataBoundary(for: "Response meta info is empty"))")
            }
        }
        
        
        if let error = logData.error {
            responseStr += "\n\nResponse Error:\n"
            responseStr += error.localizedDescription
        }
        
        responseStr += "\n\nResponse Content: \n"
        if let data = logData.receivedData, data.isEmpty == false {
            
            if formatter.logUnreadableRespBody || XNAppUtils.shared.isContentTypeReadable(logData.respContentMeta.contentType) {
                let str = XNJSONUtils().getJSONStringORStringFrom(jsonData: data, prettyPrint: formatter.prettyPrintJSON)
                responseStr.append(str)
            } else {
                responseStr.append(logData.respContentMeta.contentType.getName() + " data")
            }
        }
        else {
            responseStr.append("\(getEmptyDataBoundary(for: "*** Respose data is empty ***"))")
        }
        
        responseStr += "\n\n\(getBoundry(for: "Response End"))"
        return responseStr
    }
    
    private func getIdentifierString(_ identifier: String) -> String {
        return "\(identifier) (Generated by XNLogger)"
    }
    
    private func getBoundry(for message: String) -> String {
        return "====== \(message) ======"
    }
    
    private func getEmptyDataBoundary(for message: String) -> String {
        return "*** \(message) ****"
    }
}
