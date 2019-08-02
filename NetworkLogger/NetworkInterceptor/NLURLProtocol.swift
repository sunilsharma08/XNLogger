//
//  NLURLProtocol.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 14/04/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

open class NLURLProtocol: URLProtocol {
    
    private var session: URLSession?
    private var sessionTask: URLSessionTask?
    
    private var response: URLResponse?
    private var receivedData: Data?
    private var responseError: Error?
    private var logData: NLLogData?
    
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
            debugPrint("NL: No URL found")
        }
        
        if session == nil {
            self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
        guard let pSession = self.session,
            let urlRequest = AppUtils.shared.createNLRequest(NLURLProtocol.canonicalRequest(for: self.request))
        else { return }
        
        self.logData = NLLogData(identifier: AppUtils.shared.nextLogIdentifier(), request: urlRequest)
        self.logData?.startTime = Date()
        
        if let logData = self.logData {
            NetworkLogger.shared.logRequest(from: logData)
            NetworkLogger.shared.delegate?.networkLogger?(didStartRequest: logData)
        }
        
        self.sessionTask = pSession.dataTask(with: urlRequest)
        self.sessionTask?.resume()
    }
    
    open override func stopLoading() {
        self.logData?.setSessionState(self.sessionTask?.state)
        
        // Reason for log in console on cancel session
        // https://forums.developer.apple.com/thread/88020
        
        self.session?.invalidateAndCancel()
        self.sessionTask?.cancel()
        
        self.logData?.endTime = Date()
        self.logData?.response = self.response
        self.logData?.receivedData = self.receivedData
        self.logData?.error = self.responseError
        
        if let logData = self.logData {
            NetworkLogger.shared.logResponse(from: logData)
            NetworkLogger.shared.delegate?.networkLogger?(didReceiveResponse: logData)
        }
        
        // Make sure to clear all data. To avoid memory leaks.
        self.response = nil
        self.receivedData = nil
        self.responseError = nil
        self.sessionTask = nil
        self.session = nil
        self.logData = nil
    }
    
    override open class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
}

extension NLURLProtocol: URLSessionDataDelegate {

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
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
            self.responseError = error
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.logData?.redirectRequest = request
        self.response = response
        if let mutableRequest = request.getNSMutableURLRequest() {
            URLProtocol.removeProperty(forKey: AppConstants.NLRequestFlagKey, in: mutableRequest)
            client?.urlProtocol(self, wasRedirectedTo: mutableRequest as URLRequest, redirectResponse: response)
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error
        else { return }
        
        client?.urlProtocol(self, didFailWithError: error)
        self.responseError = error
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let challengeHandler = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: NLAuthenticationChallengeSender(handler: completionHandler))
        client?.urlProtocol(self, didReceive: challengeHandler)
    }

}

// Helper private methods
fileprivate extension NLURLProtocol {
    
    fileprivate class func shouldHandle(request: URLRequest) -> Bool {
        
        if let _ = URLProtocol.property(forKey: AppConstants.NLRequestFlagKey, in: request) {
            return false
        }
        else if (NetworkLogger.shared.filterManager.isAllowed(urlRequest: request)) {
            return true
        }
        else {
            return false
        }
    }
    
}
