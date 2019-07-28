//
//  AppUtils.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 01/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

class AppUtils {
    
    static let shared: AppUtils = AppUtils()
    static private var logIdentifier: UInt64 = 0
    
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
        return "\(AppUtils.logIdentifier)"
    }
    
    func nextLogIdentifier() -> String {
        AppUtils.logIdentifier += 1
        return "\(AppUtils.logIdentifier)"
    }
    
    func getContentType(fromMIMEType mimeString: String?) -> NLContentType {
        guard let mimeType = mimeString, mimeType.isEmpty == false
            else { return .unknown(nil) }
        let typeList: [String] = mimeType.components(separatedBy: "/")
        if typeList.count < 2 {
            return .unknown(nil)
        }
        let type: String = typeList[0].lowercased()
        let subType: String = typeList[1].lowercased()
        if type.isEmpty == true || subType.isEmpty == true {
            return .unknown(nil)
        }
        
        switch type {
        case "application":
            return getApplicationType(subType)
        case "text":
            return .text
        case "image":
            return .image
        case "audio":
            return .audio
        case "video":
            return .video
        default:
            return .unknown("\(type)/\(subType)")
        }
    }
    
    func getApplicationType(_ subTypeString: String) -> NLContentType {
        switch subTypeString {
        case "pdf":
            return .pdf
        case "json":
            return .json
        default:
            return .unknown("application/\(subTypeString)")
        }
    }
}
