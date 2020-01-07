//
//  URLRequest+cURL.swift
//  XNLogger
//
//  Created by Sunil Sharma on 18/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

internal extension URLRequest {
    
    var cURL: String {
        return RequestCurlCommand().toCurlString(request: self)
    }
    
    func httpBodyString(prettyPrint: Bool) -> String? {
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
        if data.isGzipped {
            do {
                return try data.gunzipped()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return data
    }
    
    private func getHttpBodyStream(prettyPrint: Bool) -> String? {
        guard let httpBodyData = getHttpBodyStreamData() else {
            return nil
        }
        return getJSONStringORString(data: httpBodyData, prettyPrint: prettyPrint)
    }
    
    private func getHttpBody(prettyPrint: Bool) -> String? {
        
        guard let httpBodyString = self.getStringFromHttpBody(prettyPrint: prettyPrint)
        else { return nil }
        return httpBodyString
    }

    private func getStringFromHttpBody(prettyPrint: Bool) -> String? {
        guard let httpBody = httpBody, httpBody.isEmpty == false else {
            return nil
        }
        
        if httpBody.isGzipped {
            do {
                let unzippedData = try httpBody.gunzipped()
                return getJSONStringORString(data: unzippedData, prettyPrint: prettyPrint)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        return getJSONStringORString(data: httpBody, prettyPrint: prettyPrint)
    }
    
    private func getJSONStringORString(data: Data, prettyPrint: Bool) -> String? {
        return XNJSONUtils().getJSONStringORStringFrom(jsonData: data, prettyPrint: prettyPrint)
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
    
}
