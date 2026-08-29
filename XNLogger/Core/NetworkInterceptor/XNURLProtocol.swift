//
//  XNURLProtocol.swift
//  XNLogger
//
//  Created by Sunil Sharma on 14/04/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

@preconcurrency import Foundation

open class XNURLProtocol: URLProtocol, @unchecked Sendable {

    /// Lock protecting all mutable instance state from data races between
    /// URLProtocol lifecycle methods (startLoading/stopLoading) and
    /// URLSession delegate callbacks running on different threads.
    private let stateLock = NSLock()

    private var _session: URLSession?
    private var _sessionTask: URLSessionTask?
    private var _response: URLResponse?
    private var _receivedData: Data?
    private var _responseError: Error?
    private var _logData: XNLogData?

    // MARK: - Thread-safe property accessors

    private var session: URLSession? {
        get { stateLock.lock(); defer { stateLock.unlock() }; return _session }
        set { stateLock.lock(); defer { stateLock.unlock() }; _session = newValue }
    }

    private var sessionTask: URLSessionTask? {
        get { stateLock.lock(); defer { stateLock.unlock() }; return _sessionTask }
        set { stateLock.lock(); defer { stateLock.unlock() }; _sessionTask = newValue }
    }

    private var response: URLResponse? {
        get { stateLock.lock(); defer { stateLock.unlock() }; return _response }
        set { stateLock.lock(); defer { stateLock.unlock() }; _response = newValue }
    }

    private var receivedData: Data? {
        get { stateLock.lock(); defer { stateLock.unlock() }; return _receivedData }
        set { stateLock.lock(); defer { stateLock.unlock() }; _receivedData = newValue }
    }

    private var responseError: Error? {
        get { stateLock.lock(); defer { stateLock.unlock() }; return _responseError }
        set { stateLock.lock(); defer { stateLock.unlock() }; _responseError = newValue }
    }

    private var logData: XNLogData? {
        get { stateLock.lock(); defer { stateLock.unlock() }; return _logData }
        set { stateLock.lock(); defer { stateLock.unlock() }; _logData = newValue }
    }

    // MARK: - Lifecycle

    public override init(request: URLRequest, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }

    convenience init(task: URLSessionTask, cachedResponse: CachedURLResponse?, client: URLProtocolClient?) {
        guard let request = task.currentRequest else {
            self.init(request: URLRequest(url: URL(string: "about:blank")!), cachedResponse: cachedResponse, client: client)
            return
        }
        self.init(request: request, cachedResponse: cachedResponse, client: client)
    }

    deinit {
        _session?.invalidateAndCancel()
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
        guard request.url != nil else {
            debugPrint("XNL: No URL found")
            return
        }

        // Acquire lock for the entire startLoading sequence to prevent
        // delegate callbacks from racing with setup.
        stateLock.lock()

        if _session == nil {
            _session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        }
        guard let pSession = _session,
            let urlRequest = XNAppUtils.shared.createNLRequest(XNURLProtocol.canonicalRequest(for: self.request))
        else {
            stateLock.unlock()
            return
        }

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

            _logData = XNLogData(identifier: XNAppUtils.shared.nextLogIdentifier(), request: logRequest)
        } else {
            // Incase NSMutableURLRequest copy does not work.
            _logData = XNLogData(identifier: XNAppUtils.shared.nextLogIdentifier(), request: urlRequest)
        }

        _logData?.startTime = Date()

        _sessionTask = pSession.dataTask(with: urlRequest)
        _sessionTask?.resume()
        _logData?.setSessionState(_sessionTask?.state)

        // Copy logData reference before unlocking so we can notify outside the lock.
        let logDataSnapshot = _logData
        stateLock.unlock()

        if let logData = logDataSnapshot {
            XNLogger.shared.logRequest(from: logData)
            XNLogger.shared.delegate?.xnLogger?(didStartRequest: logData)
        }
    }

    open override func stopLoading() {
        stateLock.lock()

        _logData?.setSessionState(_sessionTask?.state)

        // Capture references for cancellation outside the lock.
        let taskToCancel = _sessionTask
        let sessionToInvalidate = _session

        _logData?.endTime = Date()
        _logData?.response = _response
        _logData?.receivedData = _receivedData
        _logData?.error = _responseError
        _logData?.setSessionState(_sessionTask?.state)

        let logDataSnapshot = _logData
        stateLock.unlock()

        // Reason for log in console on cancel session
        // https://forums.developer.apple.com/thread/88020
        taskToCancel?.cancel()
        sessionToInvalidate?.invalidateAndCancel()

        if let logData = logDataSnapshot {
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
        stateLock.lock()
        _receivedData?.append(data)
        stateLock.unlock()
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        stateLock.lock()
        _response = response
        _receivedData = Data()
        stateLock.unlock()

        let cachePolicy = URLCache.StoragePolicy(rawValue: request.cachePolicy.rawValue) ?? .notAllowed
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: cachePolicy)
        completionHandler(.allow)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let taskError = error {
            client?.urlProtocol(self, didFailWithError: taskError)
            stateLock.lock()
            _responseError = taskError
            _logData?.error = _responseError
            stateLock.unlock()
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        stateLock.lock()
        _logData?.redirectRequest = request
        _response = response
        stateLock.unlock()

        if let mutableRequest = request.getNSMutableURLRequest() {
            URLProtocol.removeProperty(forKey: XNAppConstants.XNRequestFlagKey, in: mutableRequest)
            client?.urlProtocol(self, wasRedirectedTo: mutableRequest as URLRequest, redirectResponse: response)
        }
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error = error
        else { return }

        client?.urlProtocol(self, didFailWithError: error)
        stateLock.lock()
        _responseError = error
        _logData?.error = _responseError
        stateLock.unlock()
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
