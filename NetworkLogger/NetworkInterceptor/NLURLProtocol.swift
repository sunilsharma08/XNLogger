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
    private var urlRequest: URLRequest?
    
    open override class func canInit(with task: URLSessionTask) -> Bool {
        debugPrint("\(#function) task")
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
        debugPrint(#function)
        if shouldHandle(request: request) {
            return true
        }
        else {
            return false
        }
    }
    
    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        debugPrint(#function)
        return request
    }
    
    open override func startLoading() {
        print(#function)
        
//        if request.url == nil {
//            fatalError("No URL in request.")
//        }
        
        if session == nil {
            self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
        
        guard let pSession = self.session,
            let urlRequest = AppUtils.shared.createNLRequest(self.request)
        else { return }
        self.urlRequest = urlRequest
        NetworkLogger.shared.logRequest(urlRequest)
        self.sessionTask = pSession.dataTask(with: urlRequest)
        sessionTask?.resume()
//        self.sessionTask = pSession.dataTask(with: urlRequest) {[weak self] (data, urlResponse, error) in
//            guard let self = self else { return }
//
//            if let error = error {
//                // Some network error occured
//                self.client?.urlProtocol(self, didFailWithError: error)
//            }
//            else {
//                // No network error
//            }
//
//            if let response = urlResponse {
//                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
//            }
//
//            if let data = data {
//                self.client?.urlProtocol(self, didLoad: data)
//            }
//            self.client?.urlProtocolDidFinishLoading(self)
//        }
//
//        self.sessionTask?.resume()
    }
    
    open override func stopLoading() {
        print(#function)
        self.sessionTask?.cancel()
        self.sessionTask = nil
        self.session = nil
        
        NetworkLogger.shared.logResponse(for: self.request, responseData: NLResponseData(response: self.response, responseData: self.receivedData, error: self.responseError))
    }
    
}

extension NLURLProtocol: URLSessionDataDelegate {


    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print(#function)
        
        client?.urlProtocol(self, didLoad: data)
        self.receivedData?.append(data)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print(#function)
        self.response = response
        self.receivedData = Data()
        let cachePolicy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: cachePolicy)
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print(#function)
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
            self.responseError = error
        } else {
            client?.urlProtocolDidFinishLoading(self)
            self.responseError = nil
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        print(#function)
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
            self.responseError = nil
            return
        }
        client?.urlProtocol(self, didFailWithError: error)
        self.responseError = error
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print(#function)
        let challengeHandler = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: NLAuthenticationChallengeSender(handler: completionHandler))
        client?.urlProtocol(self, didReceive: challengeHandler)
    }

}

// Helper private methods
fileprivate extension NLURLProtocol {
    
    fileprivate class func shouldHandle(request: URLRequest) -> Bool {
        
        if let _ = URLProtocol.property(forKey: AppConstants.NLRequestFlagKey, in: request) {
            debugPrint("Logger url")
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
