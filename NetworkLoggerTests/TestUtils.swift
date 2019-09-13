//
//  TestUtils.swift
//  NetworkLoggerTests
//
//  Created by Sunil Sharma on 09/03/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation
@testable import NetworkLogger

extension String {
    /// stringToFind must be at least 1 character.
    func countInstances(of stringToFind: String) -> Int {
        assert(!stringToFind.isEmpty)
        var count = 0
        var searchRange: Range<String.Index>?
        while let foundRange = range(of: stringToFind, options: [], range: searchRange) {
            count += 1
            searchRange = Range(uncheckedBounds: (lower: foundRange.upperBound, upper: endIndex))
        }
        return count
    }
}

class TestUtils {
    
    class func getStringFromObject(_ obj: AnyObject) -> String? {
        
        if let subStringDict = obj as? [String: String]{
            
            let jsonData = try! JSONSerialization.data(withJSONObject: subStringDict, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            return XNJSONUtils.shared.getJsonStringFrom(jsonData:  jsonData)
        }
        return nil
    }
    
    class func isLogged(atPath path: String, subString: String, numberOfTimes: Int) -> Bool {
        do {
            /// Get the contents
            let contents = try String(contentsOf: URL(fileURLWithPath: path), encoding: .utf8)
            return contents.countInstances(of: subString) >= numberOfTimes
        }
        catch let error as NSError {
            debugPrint(error.debugDescription)
            return false
        }
    }
    
}
