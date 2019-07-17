//
//  NLLogFormatter.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 13/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

@objc
public enum NLRequestMetaInfo: Int, CaseIterable {
    
    case timeoutInterval
    case cellularAccess
    case cachePolicy
    case networkType
    case cookieStatus
    case httpPipeliningStatus
    case requestStartTime
    case threadName
}

@objc
public enum NLResponseMetaInfo: Int, CaseIterable {
    
    case statusCode
    case statusDescription
    case mimeType
    case textEncoding
    case contentLength
    case suggestedFileName
    case requestStartTime
    case duration
    case threadName
    case headers
}

@objcMembers
public class NLLogFormatter: NSObject {
    
    public var showRequest: Bool = true
    public var showResponse: Bool = true
    
    public var showReqstWithResp: Bool = false
    
    public var showCurlWithReqst: Bool = true
    public var showCurlWithResp: Bool = true
    
    public var prettyPrintJSON: Bool = true
    // Coming soon...
    //public var logUnreadableRespBody: Bool = false
    
    public var showReqstMetaInfo: [NLRequestMetaInfo] = NLRequestMetaInfo.allCases {
        didSet {
            showReqstMetaInfo = Set(showReqstMetaInfo).sorted(by: { (property1, property2) -> Bool in
                return property1.rawValue < property2.rawValue
            })
        }
    }
    
    public var showRespMetaInfo: [NLResponseMetaInfo] = NLResponseMetaInfo.allCases{
        didSet {
            showRespMetaInfo = Set(showRespMetaInfo).sorted(by: { (property1, property2) -> Bool in
                return property1.rawValue < property2.rawValue
            })
        }
    }
    
    public var showReqstMetaInfoWithResp: [NLRequestMetaInfo] = NLRequestMetaInfo.allCases {
        didSet {
            showReqstMetaInfo = Set(showReqstMetaInfo).sorted(by: { (property1, property2) -> Bool in
                return property1.rawValue < property2.rawValue
            })
        }
    }
    
    
}
