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
        
        if session == nil {
            self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
        
        guard let pSession = self.session,
            let urlRequest = AppUtils.shared.createNLRequest(self.request)
        else { return }
        NetworkLogger.shared.logRequest(urlRequest)
        self.sessionTask = pSession.dataTask(with: urlRequest) {[weak self] (data, urlResponse, error) in
            guard let self = self else { return }

            if let error = error {
                // Some network error occured
                self.client?.urlProtocol(self, didFailWithError: error)
            }
            if let response = urlResponse {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
            }

            if let data = data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            self.client?.urlProtocolDidFinishLoading(self)
            NetworkLogger.shared.logResponse(for: self.request, responseData: NLResponseData(response: urlResponse, responseData: data, error: error))
        }

        self.sessionTask?.resume()
    }
    
    open override func stopLoading() {
        print(#function)
        self.sessionTask?.cancel()
        self.sessionTask = nil
        self.session = nil
    }
    
}

extension NLURLProtocol: URLSessionDataDelegate {


    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        client?.urlProtocol(self, didLoad: data)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        let cachePolicy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: cachePolicy)
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        
        if let mutableRequest = request.getNSMutableURLRequest() {
            URLProtocol.removeProperty(forKey: AppConstants.NLRequestFlagKey, in: mutableRequest)
            client?.urlProtocol(self, wasRedirectedTo: mutableRequest as URLRequest, redirectResponse: response)
            completionHandler(mutableRequest as URLRequest)
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print(#function)
        guard let error = error
        else {
            return
        }
        client?.urlProtocol(self, didFailWithError: error)
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
