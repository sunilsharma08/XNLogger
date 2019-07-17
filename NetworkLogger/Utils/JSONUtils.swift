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
    
    func getJSONPrettyPrintFrom(jsonData data: Data) -> String? {
        if data.count == 0 {
            return nil
        }
        do {
            let jsonObj = try getJsonObjectFrom(jsonData: data)
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: [.prettyPrinted])
            guard let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else {
                debugPrint("Can't create string with data.")
                return nil
            }
            return jsonString
        } catch let parseError {
            debugPrint("JSON serialization error: \(parseError)")
            return nil
        }
    }
    
    func getJSONPrettyPrintORStringFrom(jsonData data: Data) -> String? {
        
        if let jsonStr = getJSONPrettyPrintFrom(jsonData: data) {
            return jsonStr
        } else {
            if data.count == 0 {
                return nil
            }
            return getStringFrom(data: data)
        }
    }
    
    func getStringFrom(data: Data) -> String {
        return String(decoding: data, as: UTF8.self)
    }
    
    func getDictionaryFrom(jsonData: Data) -> [String: Any]? {
        
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
