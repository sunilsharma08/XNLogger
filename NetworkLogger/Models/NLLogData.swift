//
//  NLLogData.swift
//  NetworkLogger
//
//  Created by Sunil Sharma on 09/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public enum NLSessionState: Int {
    case running
    case suspended
    case canceling
    case completed
    case unknown
    
    func getName() -> String {
        switch self {
        case .running:
            return "Running..."
        case .suspended:
            return "Suspended"
        case .canceling:
            return "Canceling"
        case .completed:
            return "Completed"
        case .unknown:
            return "Unknown"
        }
    }
}

internal enum NLContentType {
    case text
    case json
    case image
    case pdf
    case audio
    case video
    case unknown(String?)
    
    func getName() -> String {
        switch self {
        case .text:
            return "Text"
        case .json:
            return "JSON"
        case .image:
            return "Image"
        case .pdf:
            return "PDF"
        case .audio:
            return "Audio"
        case .video:
            return "Video"
        case .unknown(let name):
            if let title = name {
                return title
            }
            return "Unknown"
        }
    }
}

/**
 NLLogData model is exposed as READ only i.e. variables can be read from
 outside module but variables cannot be WRITTEN or UPDATED from outside of module.
 */
public class NLLogData: NSObject {
    
    public let identifier: String
    public let urlRequest: URLRequest
    internal(set) public var response: URLResponse?
    internal(set) public var receivedData: Data?
    internal(set) public var error: Error?
    internal(set) public var startTime: Date?
    internal(set) internal var endTime: Date? {
        didSet {
            if let startDate = startTime, let endDate = endTime {
                duration = endDate.timeIntervalSince(startDate)
            }
        }
    }
    internal(set) public var redirectRequest: URLRequest?
    private(set) public var state: NLSessionState?
    internal(set) public var duration: Double?
    
    internal(set) lazy var respContentType: NLContentType = {
        return AppUtils.shared.getContentType(fromMIMEType: response?.mimeType)
    }()
    
    internal(set) lazy var reqstContentType: NLContentType = {
        return AppUtils.shared.getContentType(fromMIMEType: urlRequest.getMimeType())
    }()
    
    internal init(identifier: String, request: URLRequest) {
        self.identifier = identifier
        self.urlRequest = request
    }
    
    internal func setSessionState(_ state: URLSessionTask.State?) {
        guard let state = state else {
            self.state = .unknown
            return 
        }
        switch state {
        case .running:
            self.state = .running
        case .suspended:
            self.state = .suspended
        case .canceling:
            self.state = .canceling
        case .completed:
            self.state = .completed
        }
    }
    
    internal func getDurationString() -> String? {
        
        guard let timeInterval: Double = duration else { return nil }
        
        // Milliseconds
        let ms = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 1000)
        // Seconds
        let s = Int(timeInterval) % 60
        // Minutes
        let mn = (Int(timeInterval) / 60) % 60
        // Hours
        let hr = (Int(timeInterval) / 3600)
        
        var readableStr = ""
        if hr != 0 {
            readableStr += String(format: "%0.2dhr ", hr)
        }
        if mn != 0 {
            readableStr += String(format: "%0.2dmn ", mn)
        }
        if s != 0 {
            readableStr += String(format: "%0.2ds ", s)
        }
        if ms != 0 {
            readableStr += String(format: "%0.3dms ", ms)
        }
        
        return readableStr
    }
}
