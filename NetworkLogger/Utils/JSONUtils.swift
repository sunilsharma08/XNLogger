//
//  JSONUtils.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 07/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class JSONUtils: NSObject {
    
    static let shared: JSONUtils = JSONUtils()
    
    private override init() {}
    
    func getJsonStringFrom(jsonData: Data) -> String {
        
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments, .mutableLeaves, .mutableContainers])
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: [.prettyPrinted])
            guard let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else {
                debugPrint("Can't create string with data.")
                return "{}"
            }
            return jsonString
        } catch let parseError {
            debugPrint("json serialization error: \(parseError)")
            return ""
        }
    }
    
    func getDictionaryStringFrom(jsonData: Data) -> [String: Any]? {
        
        do {
            if let jsonObj = try getJsonObjectFrom(jsonData: jsonData) as? [String: Any] {
                return jsonObj
            } else {
                return nil
            }
        } catch let parseError {
            debugPrint("JSON serialization error: \(parseError)")
            return nil
        }
    }
    
    func getJsonObjectFrom(jsonData: Data) throws -> Any {
        
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments, .mutableLeaves, .mutableContainers])
            return jsonObj
        } catch let parseError {
            debugPrint("JSON serialization error: \(parseError)")
            throw parseError
        }
    }

}
