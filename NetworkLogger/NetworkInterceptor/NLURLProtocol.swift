//
//  NLURLProtocol.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 14/04/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

open class NLURLProtocol: URLProtocol {
    
    var session: URLSession?
    var sessionTask: URLSessionTask?
    
    var response: URLResponse?
    var receivedData: Data?
    var responseError: Error?
    
    static var counter: UInt = 0
    
    var instCounter: UInt = 0
    
    public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
        NLURLProtocol.counter += 1
        self.instCounter = NLURLProtocol.counter
        print("\(NLURLProtocol.className) \(#function) - id \(instCounter)")
    }
    
    convenience init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        print("\(NLURLProtocol.className) \(#function)")
        self.init(request: task.currentRequest!, cachedResponse: cachedResponse, client: client)
    }
    
    open override class func canInit(with task: URLSessionTask) -> Bool {
        print("\(NLURLProtocol.className) \(#function) task")
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
        print("\(NLURLProtocol.className) \(#function)")
        if shouldHandle(request: request) {
            return true
        }
        else {
            return false
        }
    }
    
    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        print("\(NLURLProtocol.className) \(#function)")
//        var urlRequest = request
//        urlRequest.timeoutInterval = 20
        return request
    }
    
    open override func startLoading() {
        print("\(NLURLProtocol.className) \(#function)")
        if request.url == nil {
            debugPrint("NL: No URL found")
            return
        }
        
        if session == nil {
            self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
        guard let pSession = self.session,
            var urlRequest = AppUtils.shared.createNLRequest(self.request)
        else { return }
        
        if var param = urlRequest.url?.query {
            param += "&identti=\(instCounter)"
            urlRequest.url = URL(string: "\(urlRequest.url!.scheme!)://\(urlRequest.url!.host!)\(urlRequest.url!.path)?\(param)")
            print("NNNN \(String(describing: urlRequest.url?.absoluteString))")
        }
        
        print("Counter \(instCounter)")
        NetworkLogger.shared.logRequest(urlRequest)
//        if (instCounter % 3) != 0 {
        self.sessionTask = pSession.dataTask(with: urlRequest)
        self.sessionTask?.resume()
//        }
    }
    
    
    
    open override func stopLoading() {
        print("\(NLURLProtocol.className) \(#function)")
        print("Counter \(instCounter)")
        print("\(String(describing: self.sessionTask?.state.rawValue))")
        
        print("Original = \(String(describing: self.sessionTask?.originalRequest?.cURL))")
        print("Current = \(String(describing: self.sessionTask?.currentRequest?.cURL))")
//        self.sessionTask?.cancel()
//        self.session?.invalidateAndCancel()
//        self.sessionTask = nil
//        self.session = nil

        NetworkLogger.shared.logResponse(for: self.request, responseData: NLResponseData(response: response, responseData: receivedData, error: responseError))
        self.response = nil
        self.receivedData = nil
        self.responseError = nil
    }
    
    override open class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        print("\(NLURLProtocol.className) \(#function)")
        print("Cache status = \(super.requestIsCacheEquivalent(a, to: b))")
        print("a = \(String(describing: a.url?.absoluteString))")
        print("b = \(String(describing: b.url?.absoluteString))")
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
    deinit {
        print("\(NLURLProtocol.className) \(#function)")
        print("Counter \(instCounter)")
    }
    
}

extension NLURLProtocol: URLSessionDataDelegate {

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("\(NLURLProtocol.className) \(#function) dataload - id = \(instCounter)")
        print("Counter \(instCounter)")
        client?.urlProtocol(self, didLoad: data)
        self.receivedData?.append(data)
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        print("\(NLURLProtocol.className) \(#function) - first response id == \(instCounter)")
        self.response = response
        self.receivedData = Data()
        print("First response = \(LogComposer().getResponseMetaData(response: response))")
        let cachePolicy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("\(NLURLProtocol.className) \(#function) - id = \(instCounter)")
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
            self.responseError = error
            print("hhihi - > \(error.localizedDescription)")
        } else {
            client?.urlProtocolDidFinishLoading(self)
            self.responseError = nil
            print("hhihi - No error")
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        print("\(NLURLProtocol.className) \(#function) - id = \(instCounter)")
//        print("Redirect response = \(LogComposer().getResponseMetaData(response: response))")
        self.response = response
        if let mutableRequest = request.getNSMutableURLRequest() {
            print("Proterty to be remove \(String(describing: URLProtocol.property(forKey: AppConstants.NLRequestFlagKey, in: mutableRequest as URLRequest)))")
            URLProtocol.removeProperty(forKey: AppConstants.NLRequestFlagKey, in: mutableRequest)
            print("Proterty removed \(String(describing: URLProtocol.property(forKey: AppConstants.NLRequestFlagKey, in: mutableRequest as URLRequest)))")
            client?.urlProtocol(self, wasRedirectedTo: mutableRequest as URLRequest, redirectResponse: response)
            completionHandler(mutableRequest as URLRequest)
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        print("\(NLURLProtocol.className) \(#function) - id = \(instCounter)")
        guard let error = error
        else {
            print("No erroror")
            self.responseError = nil
            return
        }
        client?.urlProtocol(self, didFailWithError: error)
        self.responseError = error
        print("erroror - > \(error.localizedDescription)")
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        print("\(NLURLProtocol.className) \(#function) - id === \(instCounter)")
        let challengeHandler = URLAuthenticationChallenge(authenticationChallenge: challenge, sender: NLAuthenticationChallengeSender(handler: completionHandler))
        client?.urlProtocol(self, didReceive: challengeHandler)
    }
    
//    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
//        print("\(NLURLProtocol.className) \(#function) - id = \(instCounter)")
//    }

}

// Helper private methods
fileprivate extension NLURLProtocol {
    
    fileprivate class func shouldHandle(request: URLRequest) -> Bool {
        
        if let _ = URLProtocol.property(forKey: AppConstants.NLRequestFlagKey, in: request) {
            print("Logger URL")
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
