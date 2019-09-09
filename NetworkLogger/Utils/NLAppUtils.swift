//
//  NLAppUtils.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 01/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

class NLAppUtils {
    
    static let shared: NLAppUtils = NLAppUtils()
    static private var logIdentifier: UInt64 = 0
    lazy var mimeChecker: NLMIMEChecker = {
        return NLMIMEChecker()
    }()
    
    private init() {}
    
    /**
     Create URLRequest which skip Network Logger
     */
    func createNLRequest(_ request: URLRequest) -> URLRequest? {
        let mutableURLRequest = request.getNSMutableURLRequest()
        mutableURLRequest?.setNLFlag(value: true)
        if let urlRequest = mutableURLRequest {
            return urlRequest as URLRequest
        } else {
            return nil
        }
    }
    
    func getLogIdentifier() -> String {
        return "\(NLAppUtils.logIdentifier)"
    }
    
    func nextLogIdentifier() -> String {
        NLAppUtils.logIdentifier += 1
        return "\(NLAppUtils.logIdentifier)"
    }
    
    func getMimeEnum(from dataBytes: [UInt8]) -> NLContentType {
        return mimeChecker.getMimeType(from: dataBytes)
    }
    
    func getMimeEnum(from mimeString: String?) -> NLContentType {
        return mimeChecker.getMimeType(from: mimeString)
    }
    
    func isContentTypeReadable(_ contentType: NLContentType) -> Bool {
        switch contentType {
        case .json, .text:
            return true
        default:
            return false
        }
    }
}
