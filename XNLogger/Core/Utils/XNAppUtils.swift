//
//  XNAppUtils.swift
//  XNLogger
//
//  Created by Sunil Sharma on 01/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

class XNAppUtils {
    
    static let shared: XNAppUtils = XNAppUtils()
    static private var logIdentifier: UInt64 = 0
    lazy var mimeChecker: XNMIMEChecker = {
        return XNMIMEChecker()
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
        return "\(XNAppUtils.logIdentifier)"
    }
    
    func nextLogIdentifier() -> String {
        XNAppUtils.logIdentifier += 1
        return "\(XNAppUtils.logIdentifier)"
    }
    
    func getFileMeta(from dataBytes: [UInt8]) -> XNFileMeta {
        return mimeChecker.getFileMeta(from: dataBytes)
    }
    
    func getFileMeta(from mimeString: String?) -> XNFileMeta {
        return mimeChecker.getFileMeta(from: mimeString)
    }
    
    func isContentTypeReadable(_ contentType: XNContentType) -> Bool {
        switch contentType {
        case .json, .text, .urlencoded:
            return true
        default:
            return false
        }
    }
}
