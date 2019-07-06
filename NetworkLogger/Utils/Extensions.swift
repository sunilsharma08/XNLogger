//
//  StringExtensions.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 26/01/19.
//

import Foundation

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self)
        else { return nil }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func urlEncoded() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
    
}

extension NSObject {
    
    var className: String {
        return String(describing: type(of: self)).components(separatedBy: ".").last ?? ""
    }
    
    class var className: String {
        return String(describing: self).components(separatedBy: ".").last!
    }
}

extension URLRequest {
    
    func getNSMutableURLRequest() -> NSMutableURLRequest? {
    guard let mutableRequest = (self as NSURLRequest).mutableCopy() as? NSMutableURLRequest
    else { return nil }
    return mutableRequest
    }
}

extension NSMutableURLRequest {
    
    func setNLFlag(value: Any) {
        URLProtocol.setProperty(value, forKey: AppConstants.NLRequestFlagKey, in: self)
    }
}
