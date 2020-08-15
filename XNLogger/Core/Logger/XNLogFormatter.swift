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

@objcMembers
public class XNLogFormatter: NSObject {
    
    // Hide or show requests log.
    public var showRequest: Bool = true
    
    // Hide or show response log.
    public var showResponse: Bool = true
    
    // Show request with response, useful when `showRequest` is disabled.
    public var showReqstWithResp: Bool = false
    
    // Show curl request with request log.
    public var showCurlWithReqst: Bool = true
    
    // Show curl request when url request is displayed with response.
    public var showCurlWithResp: Bool = true
    
    // Log pretty printed json data .
    public var prettyPrintJSON: Bool = true
    
    // Show binary data like image, video, etc in response.
    public var logUnreadableRespBody: Bool = false
    
    // Show binary data like image, video, etc in request body.
    public var logUnreadableReqstBody: Bool = false
    
    // Details to be displayed in request log portion.
    public var showReqstMetaInfo: [XNRequestMetaInfo] = XNRequestMetaInfo.allCases {
        didSet {
            showReqstMetaInfo = Set(showReqstMetaInfo).sorted(by: { (property1, property2) -> Bool in
                return property1.rawValue < property2.rawValue
            })
        }
    }
    
    // Details to be displayed in response log portion.
    public var showRespMetaInfo: [XNResponseMetaInfo] = XNResponseMetaInfo.allCases{
        didSet {
            showRespMetaInfo = Set(showRespMetaInfo).sorted(by: { (property1, property2) -> Bool in
                return property1.rawValue < property2.rawValue
            })
        }
    }
    
    // Details to display for request when display as response portion.
    public var showReqstMetaInfoWithResp: [XNRequestMetaInfo] = XNRequestMetaInfo.allCases {
        didSet {
            showReqstMetaInfo = Set(showReqstMetaInfo).sorted(by: { (property1, property2) -> Bool in
                return property1.rawValue < property2.rawValue
            })
        }
    }
    
}
