//
//  XNLogFormatter.swift
//  XNLogger
//
//  Created by Sunil Sharma on 13/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

@objc
public enum XNRequestMetaInfo: Int, CaseIterable {

    case timeoutInterval
    case cellularAccess
    case cachePolicy
    case networkType
    case cookieStatus
    case httpPipeliningStatus
    case requestStartTime
}

@objc
public enum XNResponseMetaInfo: Int, CaseIterable {

    case statusCode
    case statusDescription
    case mimeType
    case textEncoding
    case contentLength
    case suggestedFileName
    case requestStartTime
    case duration
    case headers
}

/// Thread-safe log formatter. Properties are written during configuration
/// (typically at app launch) and read during log processing on background threads.
@objcMembers
public class XNLogFormatter: NSObject, @unchecked Sendable {

    private let lock = NSLock()

    // MARK: - Backing storage

    private var _showRequest: Bool = true
    private var _showResponse: Bool = true
    private var _showReqstWithResp: Bool = false
    private var _showCurlWithReqst: Bool = true
    private var _showCurlWithResp: Bool = true
    private var _prettyPrintJSON: Bool = true
    private var _logUnreadableRespBody: Bool = false
    private var _logUnreadableReqstBody: Bool = false
    private var _showReqstMetaInfo: [XNRequestMetaInfo] = XNRequestMetaInfo.allCases
    private var _showRespMetaInfo: [XNResponseMetaInfo] = XNResponseMetaInfo.allCases
    private var _showReqstMetaInfoWithResp: [XNRequestMetaInfo] = XNRequestMetaInfo.allCases

    // MARK: - Thread-safe public properties

    // Hide or show requests log.
    public var showRequest: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _showRequest }
        set { lock.lock(); defer { lock.unlock() }; _showRequest = newValue }
    }

    // Hide or show response log.
    public var showResponse: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _showResponse }
        set { lock.lock(); defer { lock.unlock() }; _showResponse = newValue }
    }

    // Show request with response, useful when `showRequest` is disabled.
    public var showReqstWithResp: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _showReqstWithResp }
        set { lock.lock(); defer { lock.unlock() }; _showReqstWithResp = newValue }
    }

    // Show curl request with request log.
    public var showCurlWithReqst: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _showCurlWithReqst }
        set { lock.lock(); defer { lock.unlock() }; _showCurlWithReqst = newValue }
    }

    // Show curl request when url request is displayed with response.
    public var showCurlWithResp: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _showCurlWithResp }
        set { lock.lock(); defer { lock.unlock() }; _showCurlWithResp = newValue }
    }

    // Log pretty printed json data.
    public var prettyPrintJSON: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _prettyPrintJSON }
        set { lock.lock(); defer { lock.unlock() }; _prettyPrintJSON = newValue }
    }

    // Show binary data like image, video, etc in response.
    public var logUnreadableRespBody: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _logUnreadableRespBody }
        set { lock.lock(); defer { lock.unlock() }; _logUnreadableRespBody = newValue }
    }

    // Show binary data like image, video, etc in request body.
    public var logUnreadableReqstBody: Bool {
        get { lock.lock(); defer { lock.unlock() }; return _logUnreadableReqstBody }
        set { lock.lock(); defer { lock.unlock() }; _logUnreadableReqstBody = newValue }
    }

    // Details to be displayed in request log portion.
    public var showReqstMetaInfo: [XNRequestMetaInfo] {
        get { lock.lock(); defer { lock.unlock() }; return _showReqstMetaInfo }
        set {
            lock.lock()
            defer { lock.unlock() }
            _showReqstMetaInfo = Set(newValue).sorted(by: { $0.rawValue < $1.rawValue })
        }
    }

    // Details to be displayed in response log portion.
    public var showRespMetaInfo: [XNResponseMetaInfo] {
        get { lock.lock(); defer { lock.unlock() }; return _showRespMetaInfo }
        set {
            lock.lock()
            defer { lock.unlock() }
            _showRespMetaInfo = Set(newValue).sorted(by: { $0.rawValue < $1.rawValue })
        }
    }

    // Details to display for request when display as response portion.
    public var showReqstMetaInfoWithResp: [XNRequestMetaInfo] {
        get { lock.lock(); defer { lock.unlock() }; return _showReqstMetaInfoWithResp }
        set {
            lock.lock()
            defer { lock.unlock() }
            _showReqstMetaInfoWithResp = Set(newValue).sorted(by: { $0.rawValue < $1.rawValue })
        }
    }

}
