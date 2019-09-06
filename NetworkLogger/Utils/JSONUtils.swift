//
//  JSONUtils.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 07/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class JSONUtils: NSObject {
    
    func getJSONStringFrom(jsonData data: Data, prettyPrint: Bool) -> String? {
        if data.isEmpty {
            return nil
        }
        do {
            let jsonObj = try getJsonObjectFrom(jsonData: data)
            var jsonWriteOption: JSONSerialization.WritingOptions = []
            if prettyPrint {
                jsonWriteOption = [.prettyPrinted]
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: jsonWriteOption)
            
            guard let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else {
                print("NL: Can't create string with data.")
                return nil
            }
            return jsonString
        } catch let parseError {
            print("NL: JSON serialization error: \(parseError)")
            return nil
        }
    }
    
    func getJSONStringORStringFrom(jsonData data: Data, prettyPrint: Bool) -> String {
        
        if let jsonStr = getJSONStringFrom(jsonData: data, prettyPrint: prettyPrint) {
            return jsonStr
        } else {
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
            print("NL: JSON serialization error: \(parseError)")
            return nil
        }
    }
    
    func getJsonObjectFrom(jsonData: Data) throws -> Any {
        do {
            let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: [])
            return jsonObj
        } catch let parseError {
            print("NL: JSON serialization error: \(parseError)")
            throw parseError
        }
    }

}
