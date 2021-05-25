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
        return CurlRequest().cURLCommand(from: self)
    }
    
    func getHttpBodyData() -> Data? {
        if let data = getHttpBodyStreamData() {
            return data
        }
        guard let httpBody = httpBody else {
            return nil
        }
        if httpBody.isGzipped {
            return try? httpBody.gunzipped()
        }
        return nil
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

class CurlRequest {
    
    func cURLCommand(from request: URLRequest) -> String {
        
        guard let url = request.url,
        let host = url.host,
        let method = request.httpMethod
        else { return "curl command could not be created" }
        
        var curlComponents: [String] = ["curl -v"]
        curlComponents.append("-X \(method)")
        
        if let credentialStorage = URLSessionConfiguration.default.urlCredentialStorage {
            let protectionSpace = URLProtectionSpace(host: host,
                                                 port: url.port ?? 0,
                                                 protocol: url.scheme,
                                                 realm: host,
                                                 authenticationMethod: NSURLAuthenticationMethodHTTPBasic)
            
            if let credentials = credentialStorage.credentials(for: protectionSpace)?.values {
                for credential in credentials {
                    guard let user = credential.user, let password = credential.password
                    else { continue }
                    curlComponents.append("-u \"\(user):\(password)\"")
                }
            }
            
            if request.httpShouldHandleCookies {
                if let cookies = HTTPCookieStorage.shared.cookies(for: url),
                    cookies.isEmpty == false {
                    let allCookies = cookies.map { "\($0.name)=\($0.value)" }.joined(separator: ";")
                    curlComponents.append("-b \"\(allCookies)\"")
                }
            }
            
            if let headerFields = request.allHTTPHeaderFields {
                for header in headerFields where header.key.lowercased() != "cookie"
                    && header.key.lowercased() != "content-length" {
                    
                    let escapedValue = header.value.replacingOccurrences(of: "\"", with: "\\\"")
                    curlComponents.append("-H \"\(header.key): \(escapedValue)\"")
                }
            }
            
            if let httpBody = request.httpBodyString(prettyPrint: true) {
                var escapedBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\"")
                escapedBody = escapedBody.replacingOccurrences(of: "\"", with: "\\\"")

                curlComponents.append("--data-binary \"\(escapedBody)\"")
            }

            curlComponents.append("\"\(url.absoluteString)\"")
        }
        
        return curlComponents.joined(separator: " \\\n\t")
    }
}
