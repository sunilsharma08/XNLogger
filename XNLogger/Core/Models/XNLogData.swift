//
//  XNLogData.swift
//  XNLogger
//
//  Created by Sunil Sharma on 09/07/19.
//  Copyright © 2019 Sunil Sharma. All rights reserved.
//

import Foundation

public enum XNSessionState: Int {
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

/**
 XNLogData model is exposed as READ only i.e. variables can be read from
 outside module but variables cannot be WRITTEN or UPDATED from outside of module.
 */
public class XNLogData: NSObject, NSCoding {
    
    public let identifier: String
    public let urlRequest: URLRequest
    internal(set) public var response: URLResponse?
    internal(set) public var receivedData: Data?
    internal(set) public var error: Error?
    internal(set) public var startTime: Date?
    internal var endTime: Date? {
        didSet {
            if let startDate = startTime, let endDate = endTime {
                duration = endDate.timeIntervalSince(startDate)
            }
        }
    }
    internal(set) public var redirectRequest: URLRequest?
    /** Store Request state like running or completed.
        Not very reliable in some case it persist wrong value like in redirect case. */
    private(set) public var state: XNSessionState?
    internal(set) public var duration: Double?
    
    lazy var respContentMeta: XNFileMeta = {
        if let mimeStr = response?.mimeType {
            return XNAppUtils.shared.getFileMeta(from: mimeStr)
        } else if receivedData != nil {
            return receivedData!.sniffMimeEnum()
        } else {
            return XNFileMeta(ext: nil, mime: nil, contentType: .unknown(nil))
        }
    }()
    
    lazy var reqstContentMeta: XNFileMeta = {
        if let mimeStr = urlRequest.getMimeType() {
            return XNAppUtils.shared.getFileMeta(from: mimeStr)
        } else {
            return urlRequest.sniffMimeEnum()
        }
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
        @unknown default:
            self.state = .unknown
        }
    }
    
    internal func getDurationString() -> String? {
        
        guard let timeInterval: Double = duration else { return nil }
        
        var readableStr = ""
        // Milliseconds
        let ms = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 1000)
        
        readableStr = "\(ms)ms"
        /** Currently formatting in unnecessary
        // Seconds
        let s = Int(timeInterval) % 60
        // Minutes
        let mn = (Int(timeInterval) / 60) % 60
        // Hours
        let hr = (Int(timeInterval) / 3600)
        
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
        */
        
        return readableStr
    }
    
    enum Key: String {
        case identifier = "identifier"
        case urlRequest = "urlRequest"
        case response = "response"
        case receivedData = "receivedData"
        case error = "error"
        case startTime = "startTime"
        case endTime = "endTime"
        case redirectRequest = "redirectRequest"
        case state = "state"
        case duration = "duration"
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(identifier, forKey: Key.identifier.rawValue)
        aCoder.encode(urlRequest, forKey: Key.urlRequest.rawValue)
        aCoder.encode(response, forKey: Key.response.rawValue)
        aCoder.encode(receivedData, forKey: Key.receivedData.rawValue)
        aCoder.encode(error, forKey: Key.error.rawValue)
        aCoder.encode(startTime, forKey: Key.startTime.rawValue)
        aCoder.encode(endTime, forKey: Key.endTime.rawValue)
        aCoder.encode(redirectRequest, forKey: Key.redirectRequest.rawValue)
        aCoder.encode(state?.rawValue, forKey: Key.state.rawValue)
        aCoder.encode(duration, forKey: Key.duration.rawValue)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let identifier = aDecoder.decodeObject(forKey: Key.identifier.rawValue) as? String,
        let urlRequest = aDecoder.decodeObject(forKey: Key.urlRequest.rawValue) as? URLRequest
        else { return nil }
        
        self.identifier = identifier
        self.urlRequest = urlRequest
        
        self.response = aDecoder.decodeObject(forKey: Key.response.rawValue) as? URLResponse
        self.receivedData = aDecoder.decodeObject(forKey: Key.receivedData.rawValue) as? Data
        self.error = aDecoder.decodeObject(forKey: Key.error.rawValue) as? Error
        self.startTime = aDecoder.decodeObject(forKey: Key.startTime.rawValue) as? Date
        self.endTime = aDecoder.decodeObject(forKey: Key.endTime.rawValue) as? Date
        self.redirectRequest = aDecoder.decodeObject(forKey: Key.redirectRequest.rawValue) as? URLRequest
        if let stateRawValue = aDecoder.decodeObject(forKey: Key.state.rawValue) as? Int {
            self.state = XNSessionState(rawValue: stateRawValue)
        }
        self.duration = aDecoder.decodeObject(forKey: Key.duration.rawValue) as? Double
        
    }
    
}
