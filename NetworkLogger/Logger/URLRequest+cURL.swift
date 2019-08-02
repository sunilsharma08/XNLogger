//
//  URLRequest+cURL.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 18/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation
import Gzip

internal extension URLRequest {
    internal var cURL: String {
        return RequestCurlCommand().toCurlString(request: self)
    }
    
    internal func httpBodyString(prettyPrint: Bool) -> String? {
        if let httpBodyString = getHttpBodyStream(prettyPrint: prettyPrint) {
            return httpBodyString
        }
        
        if let httpBodyString = getHttpBody(prettyPrint: prettyPrint) {
            return httpBodyString
        }
        return nil
    }
    
    func getHttpBodyStreamData() -> Data? {
        guard let httpBodyStream = self.httpBodyStream else {
            return nil
        }
        
        var data = Data()
        var buffer = [UInt8](repeating: 0, count: 4096)
        
        httpBodyStream.open()
        while httpBodyStream.hasBytesAvailable {
            let length = httpBodyStream.read(&buffer, maxLength: 4096)
            if length == 0 {
                break
            } else {
                data.append(buffer, count: length)
            }
        }
        httpBodyStream.close()
        return data
    }
    
    private func getHttpBodyStream(prettyPrint: Bool) -> String? {
        guard let httpBodyData = getHttpBodyStreamData() else {
            return nil
        }
        return getJSONPrettyPrintORString(data: httpBodyData, prettyPrint: prettyPrint)
    }
    
    private func getHttpBody(prettyPrint: Bool) -> String? {
        
        guard let httpBodyString = self.getStringFromHttpBody(prettyPrint: prettyPrint)
        else { return nil }
        return httpBodyString
    }

    private func getStringFromHttpBody(prettyPrint: Bool) -> String? {
        guard let httpBody = httpBody, httpBody.count > 0 else {
            return nil
        }
        
        if httpBody.isGzipped {
            do {
                let unzippedData = try httpBody.gunzipped()
                return getJSONPrettyPrintORString(data: unzippedData, prettyPrint: prettyPrint)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return getJSONPrettyPrintORString(data: httpBody, prettyPrint: prettyPrint)
    }
    
    private func getJSONPrettyPrintORString(data: Data, prettyPrint: Bool) -> String? {
        if prettyPrint {
            return JSONUtils.shared.getJSONPrettyPrintORStringFrom(jsonData: data)
        } else {
            return JSONUtils.shared.getStringFrom(data: data)
        }
    }
    
}

class RequestCurlCommand {
    
    func toCurlString(request: URLRequest) -> String{
        
        guard let url = request.url else { return "" }
        var method = "GET"
        if let aMethod = request.httpMethod {
            method = aMethod
        }
        let baseCommand = "curl -X \(method) '\(url.absoluteString)'"
        
        var command: [String] = [baseCommand]
        
        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers {
                command.append("-H '\(key): \(value)'")
            }
        }
        if let httpBodyString = request.httpBodyString(prettyPrint: false) {
            command.append("-d '\(httpBodyString)'")
        }
        return command.joined(separator: " ")
    }
    
    /**
    internal func getHttpBodyString(request: URLRequest) -> String? {
        if let httpBodyString = self.getHttpBodyStream(request: request) {
            return httpBodyString
        }
        if let httpBodyString = self.getHttpBody(request: request) {
            return httpBodyString
        }
        return nil
    }
    
    fileprivate func getHttpBodyStream(request: URLRequest) -> String? {
        guard let httpBodyStream = request.httpBodyStream else {
            return nil
        }
        let data = NSMutableData()
        var buffer = [UInt8](repeating: 0, count: 4096)
        
        httpBodyStream.open()
        while httpBodyStream.hasBytesAvailable {
            let length = httpBodyStream.read(&buffer, maxLength: 4096)
            if length == 0 {
                break
            } else {
                data.append(&buffer, length: length)
            }
        }
        return NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue) as String?
    }
    
    fileprivate func getHttpBody(request: URLRequest) -> String? {
        guard let httpBody = request.httpBody, httpBody.count > 0 else {
            return nil
        }
        guard let httpBodyString = self.getStringFromHttpBody(httpBody: httpBody) else {
            return nil
        }
        let escapedHttpBody = self.escapeAllSingleQuotes(httpBodyString)
        return escapedHttpBody
    }
    
    fileprivate func getStringFromHttpBody(httpBody: Data) -> String? {
        if httpBody.isGzipped {
            
            return String(data: try! httpBody.gunzipped(), encoding: .utf8)
        }
        if let httpBodyString = String(data: httpBody, encoding: String.Encoding.utf8) {
            return httpBodyString
        }
        return nil
    }
    
    fileprivate func escapeAllSingleQuotes(_ value: String) -> String {
        return value.replacingOccurrences(of: "'", with: "'\\''")
    }
 **/
    
}
