//
//  XNURLProtocol.swift
//  XNLogger
//
//  Created by Sunil Sharma on 14/04/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

open class XNURLProtocol: URLProtocol {
    
    private var session: URLSession?
    private var sessionTask: URLSessionTask?
    
    private var response: URLResponse?
    private var receivedData: Data?
    private var responseError: Error?
    private var logData: XNLogData?
    
    public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }
    
    convenience init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        self.init(request: task.currentRequest!, cachedResponse: cachedResponse, client: client)
    }
    
    open override class func canInit(with task: URLSessionTask) -> Bool {
        guard let request = task.currentRequest else {
            return false
        }

        if shouldHandle(request: request) {
            return true
        }
        else {
            return false
        }
    }
    
    open override class func canInit(with request: URLRequest) -> Bool {
        if shouldHandle(request: request) {
            return true
        }
        else {
            return false
        }
    }
    
    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    open override func startLoading() {
        if request.url == nil {
            debugPrint("XNL: No URL found")
        }
        
        if session == nil {
            self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
        guard let pSession = self.session,
            let urlRequest = XNAppUtils.shared.createNLRequest(XNURLProtocol.canonicalRequest(for: self.request))
        else { return }
        
        if var logRequest = urlRequest.getNSMutableURLRequest() as URLRequest? {
            if logRequest.httpShouldHandleCookies {
                let isCookiePresent = logRequest.allHTTPHeaderFields?.keys.contains(where: { (key) -> Bool in
                    return key.lowercased() == "cookie"
                })
                if isCookiePresent == false, let logUrl = urlRequest.url,
                    let cookies = HTTPCookieStorage.shared.cookies(for: logUrl),
                    cookies.isEmpty == false {
                    var cookieStr = ""
                    for (idx, cookie) in cookies.enumerated() {
                        var separator = ";"
                        if idx == cookies.endIndex - 1 {
                            separator = ""
                        }
                        cookieStr.append("\(cookie.name)=\(cookie.value)\(separator)")
                    }
                    
                    logRequest.addValue(cookieStr, forHTTPHeaderField: "cookie")
                }
            }
            
            self.logData = XNLogData(identifier: XNAppUtils.shared.nextLogIdentifier(), request: logRequest)
        } else {
            // Incase NSMutableURLRequest copy does not work.
            self.logData = XNLogData(identifier: XNAppUtils.shared.nextLogIdentifier(), request: urlRequest)
        }
        
        self.logData?.startTime = Date()
        
        self.sessionTask = pSession.dataTask(with: urlRequest)
        self.sessionTask?.resume()
        self.logData?.setSessionState(self.sessionTask?.state)
        
        if let logData = self.logData {
            XNLogger.shared.logRequest(from: logData)
            XNLogger.shared.delegate?.xnLogger?(didStartRequest: logData)
        }
    }
    
    open override func stopLoading() {
        self.logData?.setSessionState(self.sessionTask?.state)
        
        // Reason for log in console on cancel session
        // https://forums.developer.apple.com/thread/88020
        self.sessionTask?.cancel()
        self.session?.invalidateAndCancel()
        
        self.logData?.endTime = Date()
        self.logData?.response = self.response
        self.logData?.receivedData = self.receivedData
        self.logData?.error = self.responseError
        self.logData?.setSessionState(self.sessionTask?.state)
        
        if let logData = self.logData {
            XNLogger.shared.logResponse(from: logData)
            XNLogger.shared.delegate?.xnLogger?(didReceiveResponse: logData)
        }
    }
    
    override open class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
}

extension XNURLProtocol: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        self.receivedData?.append(data)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response
        self.receivedData = Data()
        let cachePolicy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: cachePolicy)
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let taskError = error {
            client?.urlProtocol(self, didFailWithError: taskError)
            self.responseError = taskError
            self.logData?.error = self.responseError
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.logData?.redirectRequest = request
        self.response = response
        if let mutableRequest = request.getNSMutableURLRequest() {
            URLProtocol.removeProperty(forKey: XNAppConstants.XNRequestFlagKey, in: mutableRequest)
            client?.urlProtocol(self, wasRedirectedTo: mutableRequest as URLRequest, redirectResponse: response)
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error
        else { return }
        
        client?.urlProtocol(self, didFailWithError: error)
        self.responseError = error
        self.logData?.error = self.responseError
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let challengeHandler = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: XNAuthenticationChallengeSender(handler: completionHandler))
        client?.urlProtocol(self, didReceive: challengeHandler)
    }
}

// Helper private methods
fileprivate extension XNURLProtocol {
    
    class func shouldHandle(request: URLRequest) -> Bool {
        
        if let _ = URLProtocol.property(forKey: XNAppConstants.XNRequestFlagKey, in: request) {
            return false
        }
        else if (XNLogger.shared.filterManager.isAllowed(urlRequest: request)) {
            return true
        }
        else {
            return false
        }
    }
}
