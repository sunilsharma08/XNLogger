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

public class NLLogData: NSObject {
    
    public let identifier: String
    public let urlRequest: URLRequest
    internal(set) public var response: URLResponse?
    internal(set) var receivedData: Data?
    internal(set) var error: Error?
    internal(set) var startTime: Date?
    internal(set) var endTime: Date? {
        didSet {
            if let startDate = startTime, let endDate = endTime {
                duration = endDate.timeIntervalSince(startDate)
            }
        }
    }
    internal(set) var redirectRequest: URLRequest?
    private(set) var state: NLSessionState?
    public var duration: Double?
    
    init(identifier: String, request: URLRequest) {
        self.identifier = identifier
        self.urlRequest = request
    }
    
    func setSessionState(_ state: URLSessionTask.State?) {
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
    
    func getDurationString() -> String? {
        
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
