//
//  XNJSONUtils.swift
//  XNLogger
//
//  Created by Sunil Sharma on 07/01/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import UIKit

class XNJSONUtils: NSObject {
    
    func getJSONStringFrom(jsonData data: Data, prettyPrint: Bool) -> String? {
        guard data.isEmpty == false, let jsonObj = getJsonObjectFrom(jsonData: data)
        else { return nil }
        
        var jsonWriteOption: JSONSerialization.WritingOptions = []
        if prettyPrint {
            jsonWriteOption = [.prettyPrinted]
        }
        if #available(iOS 13.0, *) {
            jsonWriteOption.update(with: .withoutEscapingSlashes)
        } else {
            // Fallback on earlier versions
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObj, options: jsonWriteOption)
            return getStringFrom(data: jsonData)
        } catch let parseError {
            print("XNL: JSON serialization error: \(parseError)")
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
        return getJsonObjectFrom(jsonData: jsonData) as? [String: Any]
    }
    
    func getJsonObjectFrom(jsonData: Data) -> Any? {
        try? JSONSerialization.jsonObject(with: jsonData, options: [])
    }
}
